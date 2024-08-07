import boto3

def get_compute_optimizer_recommendations():
    # Create a Compute Optimizer client
    compute_optimizer_client = boto3.client('compute-optimizer')

    # Get EC2 recommendations
    response = compute_optimizer_client.get_ec2_instance_recommendations()

    recommendations = response['instanceRecommendations']

    for recommendation in recommendations:
        instance_id = recommendation['instanceArn'].split('/')[-1]
        finding = recommendation['finding']
        estimated_monthly_savings = recommendation.get('utilizationMetrics', [])[0].get('estimatedMonthlySavings', {}).get('amount', 0)
        
        # Get On-Demand price (assuming USD, adapt as needed)
        current_on_demand_price = recommendation.get('utilizationMetrics', [])[0].get('onDemandCost', {}).get('amount', 0)
        
        print(f"Instance ID: {instance_id}")
        print(f"Finding: {finding}")
        print(f"Current On-Demand Price: ${current_on_demand_price}")
        print(f"Estimated Monthly Savings (On-Demand): ${estimated_monthly_savings}")
        print('-' * 40)

if __name__ == "__main__":
    get_compute_optimizer_recommendations()
