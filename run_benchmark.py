import timeit
import json
import math
import tomli

data = open("benchmark/data.toml").read()

REPEATS = 30
PARSES = 500

times = timeit.repeat(lambda: tomli.loads(data), number=PARSES, repeat=REPEATS)

avg_time = sum(times) / len(times)
std_time = math.sqrt(sum((t - avg_time) ** 2 for t in times) / len(times))

results = [{
    "repeats": REPEATS,
    "parses_per_trial": PARSES,
    "throughput_parses_per_sec": round(PARSES / avg_time, 2),
    "throughput_std_parses_per_sec": round(PARSES / (avg_time ** 2) * std_time, 2),
    "avg_time_for_500_parses_sec": round(avg_time, 6),
    "std_time_for_500_parses_sec": round(std_time, 6),
    "ms_per_parse_mean": round((avg_time / PARSES) * 1000, 4),
    "ms_per_parse_std": round((std_time / PARSES) * 1000, 4),
}]

with open("artemis_results.json", "w") as f:
    json.dump(results, f)

print(json.dumps(results))
