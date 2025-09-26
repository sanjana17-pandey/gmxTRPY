import re
import csv
import os

def extract_values(
    regex_pattern,
    file_template,
    window=10000,
    step=5000,
    tmax=1000000,
    output_csv="values.csv"
):
    """
    Extracts values from sequential log files and writes them to a CSV.

    Parameters:
        regex_pattern (str): Regex pattern to extract the desired value.
        file_template (str): Template for log filenames, with {start} and {end} placeholders.
        window (int): Size of the window (default 10000).
        step (int): Step between windows (default 5000).
        tmax (int): Maximum simulation time (default 1000000).
        output_csv (str): Output CSV filename (default 'values.csv').
    """
    pattern = re.compile(regex_pattern)

    with open(output_csv, "w", newline="") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["start_ps", "end_ps", "value"])

        start = 0
        while start + window <= tmax:
            end = start + window
            filename = file_template.format(start=start, end=end)

            if not os.path.isfile(filename):
                print(f"{filename} not found. Skipping.")
                start += step
                continue

            with open(filename, "r") as f:
                for line in f:
                    match = pattern.search(line)
                    if match:
                        value = match.group(1)
                        writer.writerow([start, end, value])
                        break  # stop after first match per file

            start += step

if __name__ == "__main__":
    # Example usage for Schlitter entropy
    extract_values(
        regex_pattern=r"The Entropy due to the Schlitter formula is ([\d.]+) J/mol K",
        file_template="entropy_{start}_{end}.log",
        window=10000,
        step=5000,
        tmax=1000000,
        output_csv="entropy_values.csv"
    )
