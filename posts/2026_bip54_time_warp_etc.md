*[ Editorial - this is a WIP draft

*It needs to be accompanied by diagrams.*
*After having written most of this I noticed there are some quite helpful ones for Time warp and Murch-Zawy at https://bitcoinops.org/en/newsletters/2024/08/16/#new-time-warp-vulnerability-in-testnet4*

*]*

The previous soft fork, Taproot, introduced a lot of new functionality. In contrast, the BIP54 Consensus Cleanup only narrows what is allowed. It adds restrictions on:

 * Block header timestamp values.
 * Coinbase transaction lock times.
 * Transaction sizes.
 * Sigop-counts across blocks.

This post focuses on the added restrictions to timestamp values.


## Narrowed block timestamp rules

With a trustless system like the Bitcoin blockchain, the protocol has no single source of time to verify the validity of timestamps in the block headers. Furthermore, new nodes joining in the future need to be able to replay and validate the blockchain.

Current consensus rules say:
 * No future blocks: Nodes should not accept blocks with a timestamp more than 2 hours in the future of the local system clock.
 * Median time past (MTP) rule: Each block must be timestamped as being from at least 1 second later than the timestamp of the median timestamp of the 11 previous blocks.


## Thought experiment: faking the slowest chain

Technically miners could start mining blocks after the genesis block for whom the (faked) timestamp only increases 1 second every 6 blocks. That way timestamps would be slowly increasing from the Unix Epoch time 1231006505 (Saturday, January 3, 2009 6:15:05 PM GMT). At 930'000 blocks the fork would still be at Monday, January 5, 2009 1:18:25 PM.

Doing that would throw off the Difficulty Adjustment Algorithm (DAA). It cannot verify that timestamps in blocks reflect true UTC time, it just has to work with what it can deterministically check. The DAA compares timestamps between the first and last blocks of the 2016-block Difficulty Adjustment Interval (DAI), block #0 vs block #2015. The small difference in seconds makes it think we are mining way too fast, and make it increase the difficulty by the maximum of 4x every 2016 blocks in order to slow down miners and reach an average of ~10 mins/block. (Satoshi made an off-by-one error in counting blocks so the algorithm doesn't aim for exactly 10 mins). Such a chain would be the hardest possible fork. That would lead to much more than 10 mins wall time on average to produce new blocks, and become less popular with miners. Miners are therefore somewhat incentivized to use something close to their wall-time in order for the whole mining game to work.


## Time warp attack

How about the incentives for someone trying to wreak havoc on Bitcoin?

To avoid the 4x difficulty-increase, we can stick to only increasing the timestamp every 6 blocks, but set the timestamp of the last block of the DAI to 2 hours in the future. That way we get a maximally large time-difference between first (#0) and last blocks (#2015) in the DAI (provided that we want the last block to be accepted in real time by the rest of the network). As we continue mining the next DAI's blocks, due to how MTP works (essentially ignoring the last block due to it not being the median of the previous 11), we can snap back to ~6 minutes after the first block of the previous DAI. Again on the last block of the DAI we set the timestamp 2 hours in the future. During those two DAIs we would be mining at roughly the same difficulty, but once the DAA kicks in to compare the timestamps of block #2016 and #4031, it sees that instead of the ideal 2 weeks, 4 weeks have passed in timestamp time. This means the difficulty should halve for the 3rd DAI. This procedure can be repeated to keep decreasing the difficulty in order to actually reach the theoretical limit of the MTP rule - 6 blocks being produced per *actual* second, given sufficient hash power.

The two things that currently combine to counter this attack is that a majority of miners don't try to wreak havoc and that the Bitcoin protocol specifies that it is the chain with the highest accumulated PoW that matters.

Only having sufficient hash rate to attempt to repeatedly mine & fork off at the first and last blocks of a DAI isn't sufficient due to the MTP rule forcing forward progress in blocks in-between.


### Testnet 3 & 4

People have wreaked havoc on Testnet 3 by performing block storms - exploiting the 20 minute exception rule which resets difficulty down to the network's absolute minimum (`nBits = 0x1d00ffff`) on the last block of the difficulty period. That extremely low difficulty would then be used as the reference-value for the DAA.

[Testnet 4 / BIP94](https://github.com/bitcoin/bips/blob/master/bip-0094.mediawiki) adjusts the DAA in two ways:

<ol type="A">
<li>When calculating the difficulty of the first block of a new DAI, instead of using the difficulty of the directly preceding block as reference-value, we use the first block of the preceding DAI. That way we aren't subject to the 20 minute exception, given that it only applies to blocks which are not the first of a DAI.</li>
<li>The timestamp of the first block in a DAI must be >= the timestamp of the immediately preceding block -600 seconds.</li>
</ol>

The timestamp new rule from Testnet 4 (B above) to restrict timestamps of the first block in a DAI was [first proposed in the original Consensus Cleanup proposal](https://github.com/TheBlueMatt/bips/blob/cleanup-softfork/bip-XXXX.mediawiki?plain=1#L40). By putting a constraint on last block of DAI+next first block of a DAI, we are influencing the input parameters of the DAA, which are the timestamps of the first and last blocks.

However, Testnet 4 still leaves room for at least one type of timestamp-related attack.


## Murch-Zawy attack

If an attacker plans to only activate their attack multiple weeks in the future, they can circumvent the 2 hour rule until that time, setting the timestamp of the last block in each DAI to be further in the future than 2 hours.

Probably the main goal of this attack is to wreak havoc as well. Secondary goals of the attack though is to produce more PoW and blocks (to gain extra subsidy vs mining on the honest fork), within a given time interval than the honest chain. While still having the tip of our attack fork be within 2 hours of the current time at the time we publish it.

The MTP rule enforces that a block's timestamp is greater than the median timestamp of the preceding 11 blocks. Classic Time warp attack exploited that by abusing one of the slots prior to the median 6th block. *[<- Needs to be clarified ->]* Instead of abusing one slot we can abuse two and still conform to the "first block of DAI's timestamp cannot be before preceeding block"-rule used on Testnet 4. This allows us to keep time creeping along from difficulty period 1 into difficulty 2 despite the speedbumps of the DAI 1s last and DAI 2s first blocks which are set further in the future to trick the DAA while still abiding by something like the Testnet 4 timestamp rule.

So the attacker can decide that they will not announce their fork until 8 weeks from the start of a new DAI.

Why would they want to increase the difficulty? They still need to contend with wall time.

What makes Murch-Zawy more problematic than a regular 51% attack?
Not much, aside from the block subsidy being consumed faster than a fork that only censored transactions for example.

*[...section needs more work...]*

David Harding adds some good context: https://delvingbitcoin.org/t/zawy-s-alternating-timestamp-attack/1062/23


## The BIP54 fix

 * The timestamp of the first block of a DAI must be >= the timestamp of the last block in the previous DAI. (Already active on Testnet 4, see above, although the offset was increased from -600 to -7200 seconds).
 * The timestamp of the last block in the DAI must be >= the timestamp of the first block in the DAI. (New in BIP54 to mitigate Murch-Zawy attacks *[can't see how this would be a problem for the "new timewarp" diagram in https://bitcoinops.org/en/newsletters/2024/08/16/#new-time-warp-vulnerability-in-testnet4]*).

This way one cannot exploit MTP to warp the first block of a difficulty period back to ~6 minutes after the first block of the last period (Time warp). One also cannot make the difference between the timestamps of the first and last blocks of the same period negative... *[..... <- rly? WIP. ]*


## Is it the best fix though?

I think Zawy[^1][^2][^3][^4] makes a strong case in encouraging monotonicity for all block header timestamps, not just for the first and last blocks of a DAI. The lax rules of MTP and 2 hour future block time is not just an issue for OpenTimestamps, it is an issue for CSV and CLT calculations themselves. It would be nice if a minority of miners writing fairly accurate timestamps could force the rest of the miners to keep a somewhat regular timestamp, as long as it doesn't create too much of an incentive to re-org out their blocks. (Another approach Zawy mentions[^5] is that in the case of 2 competing blocks at the same height, bias towards building on top of the timestamp closest to one's own clock upon time of arrival).

Possible issue with monotonicity - if the block timestamp is used as an extra nonce field for mining, miners could aim to always mine timestamps 2h into the future in order to minimize the available valid room for nonce-scrambling for their competition, increasing the risk of stale blocks (but that goes for themselves too).

Reflection: Maybe this is an issue for me because of my hangover of sycophantic St. Satoshi-syndrome and the expectation of Bitcoin being closer to perfection. Zawy seems to think there might be other attacks lurking that would be mitigated by monotonic timestamps though.

[^1]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/55
[^2]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/57
[^3]: https://delvingbitcoin.org/t/zawy-s-alternating-timestamp-attack/1062
[^4]: https://delvingbitcoin.org/t/zawy-s-alternating-timestamp-attack/1062/15
[^5]: https://delvingbitcoin.org/t/where-does-the-33-33-threshold-for-selfish-mining-come-from/1757/2


*[ Editorial - lengthier explanations for the points at the top*

 * *The timestamps of the first block in the difficulty adjustment interval (DAI) must be higher or equal to the preceding block. The time stamp of the last block in the difficulty adjustment interval must be greater than the timestamp of the first block in the interval.*
 * *Requiring lock times height-1 lock time (and non-final sequence value) for coinbase transactions to avoid duplicate transaction hashes/ids.*
 * *Banning 64-byte transactions to simplify building SPV clients.*
 * *Counting sigops from spent outputs of previous blocks in addition to input sigops for the current block.*

*]*
