# Model routing policy
Models are evaluated per task type, not by one global leaderboard.

Reference router minimum comparable samples: 3.

Default score weights:
- 55% success rate
- 30% normalized reviewer quality
- 10% rework efficiency
- 5% cost efficiency when cost data exists

Latency is reported but not in the default score. With insufficient evidence, use the role/profile default model rather than overfitting sparse data.
