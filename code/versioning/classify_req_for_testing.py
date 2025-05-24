import pandas as pd

def sample_requirements(input_file, output_file1, output_file2, sample_size=100):
    # Read the CSV file
    df = pd.read_csv(input_file)

    # Group by requirement_pattern and sample for each group
    sampled_df = df.groupby('requirement_pattern').apply(
        lambda x: x.sample(n=min(sample_size, len(x)), random_state=42)
    ).reset_index(drop=True)

    # Write to CSV file
    sampled_df.to_csv(output_file1, index=False)

    # get the rows where requirement_type != requirement_pattern
    mismatched_rows = df[df['requirement_type'] != df['requirement_pattern']]
    mismatched_rows.to_csv(output_file2, index=False)

def main():
    input_file = '/home/imranur/security-metrics/data/dep_status/all_req-updated.csv'
    output_file1 = '/home/imranur/security-metrics/data/dep_status/all_req-updated-sampled_requirements.csv'
    output_file2 = '/home/imranur/security-metrics/data/dep_status/all_req-updated-sampled_requirements_mismatched.csv'
    sample_requirements(input_file, output_file1, output_file2, sample_size=1000)

    

if __name__ == "__main__":
    main()