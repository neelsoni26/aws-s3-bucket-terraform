# aws-s3-bucket-terraform
AWS S3 Bucket Creation and Management with Terraform.

Day 67 of #90DaysOfDevOps

### AWS S3 Bucket

Amazon S3 (Simple Storage Service) is an object storage service that offers industry-leading scalability, data availability, security, and performance. It can be used for a variety of use cases, such as storing and retrieving data, hosting static websites, and more.

In this task, we will learn how to create and manage S3 buckets in AWS using Terraform.

### Task

* Create an S3 bucket using Terraform.
    
* Configure the bucket to allow public read access.
    
* Create an S3 bucket policy that allows read-only access to a specific IAM user or role.
    
* Enable versioning on the S3 bucket.
    

---

Enter the terraform and provider block:

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.awsRegion
}
```

### 1: Create an S3 bucket using Terraform.

```
resource "aws_s3_bucket" "myBucket" {
  bucket = "day67-bucket"
  tags = {
    Name = "Day 67 Bucket"
  }
}
```

Here, resource block `aws_s3_bucket` will create s3 bucket with the name from `bucket`

So, a S3 bucket with the name `day67-bucket` will be created.

### 2: Configure the bucket to allow public read access.

```

resource "aws_s3_bucket_ownership_controls" "myBucket" {
  bucket = aws_s3_bucket.myBucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "myBucket" {
  bucket                  = aws_s3_bucket.myBucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "myBucket" {
  bucket     = aws_s3_bucket.myBucket.id
  acl        = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.myBucket, aws_s3_bucket_public_access_block.myBucket]
}
```

To set the ownership, the `aws_s3_bucket_ownership_controls` block is used and in the `rule` block the ownership is defined as `bucketownerpreferred`

As I don’t want to provide many permissions, it has been controlled by the `aws_s3_bucket_public_access_block` block.

In the `aws_s3_bucket_acl` block, the acl public-read will grant the access of publicly readable access to the `bucket` (myBucket). This block will get the required data from the `aws_s3_bucket_ownership_controls` and `aws_s3_bucket_public_access_block` block, and hence, it is defined in the `depends_on` attribute.

### 3: Create an S3 bucket policy that allows read-only access to a specific IAM user or role.

```
resource "aws_s3_bucket_policy" "Allow_access_from_another_account" {
  bucket = aws_s3_bucket.myBucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.
}
```

`aws_s3_bucket_policy` block used for attaching policy to the bucket. The policy is defined in the next data block:

```
data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [680579562058]
    }
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.myBucket.arn,
      "${aws_s3_bucket.myBucket.arn}/*",
    ]
  }
}
```

In `aws_iam_policy_document` data block, the policy is defined for granting the access of certain policies (`actions`) to the user(`identifier`)

### 4: Enable versioning on the S3 bucket

```
resource "aws_s3_bucket_versioning" "myBucket_versioning" {
  bucket = aws_s3_bucket.myBucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
```

In this block the `versioning_configuration` `status` is used to `enable` and `disable` the versioning of the s3 bucket.

After writing this code, init the terraform with `terraform init` and then apply.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1705410571714/c4fec6e1-6e14-47ae-ba27-5fab6dd33dd9.png)

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1705410580267/3aecace7-68be-49df-968d-fb95815e0e38.png)

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1705410584354/f2e7c500-e99d-43af-99b4-71433540e19c.png)

AWS Console S3 bucket:

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1705410616175/2d97999d-9b49-470b-b6fd-1053bd767a3f.png)

Bucket Versioning = Enabled

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1705410621671/166da335-e907-44a9-b902-a2f928e2cc92.png)

Public access:

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1705410632183/428df6e0-d24d-40e7-982f-ecc18bdf7470.png)

Bucket Policy

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1705410635924/81bcb436-d8d7-4131-8900-cf686cca134f.png)

Ownership:

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1705410641743/be5213ef-5ac9-4eff-96a0-36b48939e86c.png)

Access Control List:

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1705410645590/62a592e3-5040-44f2-9134-74fe56cf4522.png)

---

Thank you for reading!

If you find this helpful, make sure to like and share the blog 🧑‍💻