import * as cdk from 'aws-cdk-lib';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as lambdaNodejs from 'aws-cdk-lib/aws-lambda-nodejs';
import * as logs from 'aws-cdk-lib/aws-logs';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as s3n from 'aws-cdk-lib/aws-s3-notifications';
import { Construct } from 'constructs';

export interface LambdaStackProps extends cdk.StackProps {
  environment: string;
}

export class LambdaStack extends cdk.Stack {
  public readonly imageResizeFunction: lambda.Function;
  public readonly orderEventConsumerFunction: lambda.Function;
  public readonly paymentEventConsumerFunction: lambda.Function;
  public readonly notificationSenderFunction: lambda.Function;

  constructor(scope: Construct, id: string, props: LambdaStackProps) {
    super(scope, id, props);

    const { environment } = props;

    // ============================================
    // Image Resize Lambda Function
    // ============================================
    this.imageResizeFunction = new lambdaNodejs.NodejsFunction(this, 'ImageResizeFunction', {
      functionName: `doa-market-${environment}-image-resize`,
      runtime: lambda.Runtime.NODEJS_20_X,
      entry: '../../lambda/image-resize/index.ts',
      handler: 'handler',
      timeout: cdk.Duration.seconds(30),
      memorySize: 1024,
      environment: {
        NODE_ENV: environment,
        RESIZED_BUCKET: `doa-market-${environment}-resized-images`,
      },
      bundling: {
        minify: true,
        sourceMap: true,
        externalModules: ['aws-sdk'],
      },
      logRetention: logs.RetentionDays.ONE_WEEK,
      tracing: lambda.Tracing.ACTIVE,
    });

    // Grant permissions to read from uploads bucket and write to products bucket
    const uploadsBucket = s3.Bucket.fromBucketName(
      this,
      'UploadsBucket',
      `doa-market-${environment}-uploads`
    );
    const productsBucket = s3.Bucket.fromBucketName(
      this,
      'ProductsBucket',
      `doa-market-${environment}-products`
    );

    uploadsBucket.grantRead(this.imageResizeFunction);
    productsBucket.grantWrite(this.imageResizeFunction);

    // Add S3 event notification
    uploadsBucket.addEventNotification(
      s3.EventType.OBJECT_CREATED,
      new s3n.LambdaDestination(this.imageResizeFunction),
      { prefix: 'uploads/', suffix: '.jpg' }
    );
    uploadsBucket.addEventNotification(
      s3.EventType.OBJECT_CREATED,
      new s3n.LambdaDestination(this.imageResizeFunction),
      { prefix: 'uploads/', suffix: '.png' }
    );

    // ============================================
    // Order Event Consumer Lambda
    // ============================================
    this.orderEventConsumerFunction = new lambdaNodejs.NodejsFunction(
      this,
      'OrderEventConsumerFunction',
      {
        functionName: `doa-market-${environment}-order-event-consumer`,
        runtime: lambda.Runtime.NODEJS_20_X,
        entry: '../../lambda/order-event-consumer/index.ts',
        handler: 'handler',
        timeout: cdk.Duration.seconds(60),
        memorySize: 512,
        environment: {
          NODE_ENV: environment,
          DYNAMODB_TABLE: `doa-market-${environment}-order-events`,
        },
        bundling: {
          minify: true,
          sourceMap: true,
          externalModules: ['aws-sdk'],
        },
        logRetention: logs.RetentionDays.TWO_WEEKS,
        tracing: lambda.Tracing.ACTIVE,
        reservedConcurrentExecutions: environment === 'production' ? 100 : 10,
      }
    );

    // Grant DynamoDB permissions
    this.orderEventConsumerFunction.addToRolePolicy(
      new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: [
          'dynamodb:PutItem',
          'dynamodb:UpdateItem',
          'dynamodb:GetItem',
          'dynamodb:Query',
        ],
        resources: [
          `arn:aws:dynamodb:${this.region}:${this.account}:table/doa-market-${environment}-order-events`,
          `arn:aws:dynamodb:${this.region}:${this.account}:table/doa-market-${environment}-order-events/index/*`,
        ],
      })
    );

    // Grant EventBridge permissions
    this.orderEventConsumerFunction.addToRolePolicy(
      new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: ['events:PutEvents'],
        resources: [
          `arn:aws:events:${this.region}:${this.account}:event-bus/doa-market-${environment}-event-bus`,
        ],
      })
    );

    // ============================================
    // Payment Event Consumer Lambda
    // ============================================
    this.paymentEventConsumerFunction = new lambdaNodejs.NodejsFunction(
      this,
      'PaymentEventConsumerFunction',
      {
        functionName: `doa-market-${environment}-payment-event-consumer`,
        runtime: lambda.Runtime.NODEJS_20_X,
        entry: '../../lambda/payment-event-consumer/index.ts',
        handler: 'handler',
        timeout: cdk.Duration.seconds(60),
        memorySize: 512,
        environment: {
          NODE_ENV: environment,
        },
        bundling: {
          minify: true,
          sourceMap: true,
          externalModules: ['aws-sdk'],
        },
        logRetention: logs.RetentionDays.TWO_WEEKS,
        tracing: lambda.Tracing.ACTIVE,
      }
    );

    // Grant Secrets Manager permissions for PG API keys
    this.paymentEventConsumerFunction.addToRolePolicy(
      new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: ['secretsmanager:GetSecretValue'],
        resources: [
          `arn:aws:secretsmanager:${this.region}:${this.account}:secret:doa-market/pg-api-keys/*`,
        ],
      })
    );

    // ============================================
    // Notification Sender Lambda
    // ============================================
    this.notificationSenderFunction = new lambdaNodejs.NodejsFunction(
      this,
      'NotificationSenderFunction',
      {
        functionName: `doa-market-${environment}-notification-sender`,
        runtime: lambda.Runtime.NODEJS_20_X,
        entry: '../../lambda/notification-sender/index.ts',
        handler: 'handler',
        timeout: cdk.Duration.seconds(30),
        memorySize: 256,
        environment: {
          NODE_ENV: environment,
        },
        bundling: {
          minify: true,
          sourceMap: true,
          externalModules: ['aws-sdk'],
        },
        logRetention: logs.RetentionDays.ONE_WEEK,
        tracing: lambda.Tracing.ACTIVE,
      }
    );

    // Grant SES permissions
    this.notificationSenderFunction.addToRolePolicy(
      new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: ['ses:SendEmail', 'ses:SendRawEmail'],
        resources: ['*'],
      })
    );

    // Grant SNS permissions for SMS
    this.notificationSenderFunction.addToRolePolicy(
      new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: ['sns:Publish'],
        resources: ['*'],
      })
    );

    // ============================================
    // Lambda Function URLs (for testing)
    // ============================================
    if (environment !== 'production') {
      const imageResizeFunctionUrl = this.imageResizeFunction.addFunctionUrl({
        authType: lambda.FunctionUrlAuthType.AWS_IAM,
      });

      new cdk.CfnOutput(this, 'ImageResizeFunctionUrl', {
        value: imageResizeFunctionUrl.url,
        description: 'Image Resize Function URL',
      });
    }

    // ============================================
    // Outputs
    // ============================================
    new cdk.CfnOutput(this, 'ImageResizeFunctionArn', {
      value: this.imageResizeFunction.functionArn,
      description: 'Image Resize Lambda Function ARN',
      exportName: `${environment}-ImageResizeFunctionArn`,
    });

    new cdk.CfnOutput(this, 'OrderEventConsumerFunctionArn', {
      value: this.orderEventConsumerFunction.functionArn,
      description: 'Order Event Consumer Lambda Function ARN',
      exportName: `${environment}-OrderEventConsumerFunctionArn`,
    });

    new cdk.CfnOutput(this, 'PaymentEventConsumerFunctionArn', {
      value: this.paymentEventConsumerFunction.functionArn,
      description: 'Payment Event Consumer Lambda Function ARN',
      exportName: `${environment}-PaymentEventConsumerFunctionArn`,
    });

    new cdk.CfnOutput(this, 'NotificationSenderFunctionArn', {
      value: this.notificationSenderFunction.functionArn,
      description: 'Notification Sender Lambda Function ARN',
      exportName: `${environment}-NotificationSenderFunctionArn`,
    });

    // ============================================
    // Tags
    // ============================================
    cdk.Tags.of(this).add('Environment', environment);
    cdk.Tags.of(this).add('ManagedBy', 'CDK');
    cdk.Tags.of(this).add('Project', 'DOA Market');
  }
}
