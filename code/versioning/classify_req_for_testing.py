import pandas as pd

def sample_requirements(input_file, output_file, sample_size=100):
    # Read the CSV file
    df = pd.read_csv(input_file)

    # Group by requirement_pattern and sample for each group
    sampled_df = df.groupby('requirement_pattern').apply(
        lambda x: x.sample(n=min(sample_size, len(x)), random_state=44)
    ).reset_index(drop=True)

    # Write to CSV file
    sampled_df.to_csv(output_file, index=False)

def main():
    input_file = '/home/imranur/security-metrics/data/dep_status/all_req-updated.csv'
    output_file = '/home/imranur/security-metrics/data/dep_status/all_req-updated-sampled_requirements.csv'
    sample_requirements(input_file, output_file)

if __name__ == "__main__":
    main()