# Google Cloud Function Gen2 Template
[![codecov](https://codecov.io/github/CthtufsPetProjects/google-cloud-function-gen2-template/branch/main/graph/badge.svg?token=feLHCIidDN)](https://codecov.io/github/CthtufsPetProjects/google-cloud-function-gen2-template)

A template for creating Python functions on the Google Cloud Functions (Gen2) platform with CI/CD integration using GitHub Actions.

## Description

This project provides a ready-to-use structure for developing and deploying Python functions on Google Cloud Functions Gen2. It includes continuous integration and delivery setup with GitHub Actions, tools for testing, and dependency management.

### Why This Project Was Created

I am an entrepreneur and researcher passionate about creating new products, testing hypotheses, and automating business processes. My core belief is that hypotheses should be tested quickly and with minimal cost. That's why I use serverless functionality, which can be deployed instantly. With platforms like Google Cloud's pay-as-you-go model, projects with low usage do not incur unnecessary expenses.

To ensure scalability, maintainability, and ease of development for successful projects, I incorporate quality control tools such as type checkers, linters, tests, and code coverage tools. These minimize errors and improve code quality.

I have also set up a CI/CD pipeline, enabling fast team collaboration and quick production deployments. This ensures efficient development cycles.

In this project, I implemented two types of handlers and three types of event issuers:
1. **HTTP request handlers** – For handling synchronous HTTP requests.
2. **Queue event handlers** – For processing asynchronous messages from a queue.

### Declarative Infrastructure

I prefer a declarative approach, and the entire infrastructure for this project is described using Terraform manifests.

### Event Issuers:
1. **HTTP Webhooks** – For triggering events based on external sources.
2. **Queue publishing** – For sending messages to a queue for further processing by Google Cloud Functions.
3. **Scheduled publishing** – For recurring tasks, such as executing small, repetitive jobs.

---

## Use Case Example

To demonstrate this template's capabilities, I implemented the following use case:

1. **Scheduled Events:**
   - Google Cloud Scheduler sends an event to a queue every hour.

2. **Queue Processing:**
   - A Google Cloud Function processes the event from the queue and passes it through a series of handlers.
   - Currently, one handler is implemented: `CheckSiteForUpdate`. This handler checks if specific keywords on a given website (or websites) have changed. If changes are detected, it sends a webhook notification.

3. **Notification Example:**
   - In this implementation, the webhook sends a notification to a Telegram Bot, which forwards the alert directly to my Telegram account. (The Telegram interaction implemented in a third-party service)

4. **Manual Trigger:**
   - An HTTP request handler is also implemented (used by the same Telegram Bot) to send a message to the queue, triggering an out-of-schedule website update check.

---

## Installation

1. **Install the required tools:**
   - [pyenv](https://github.com/pyenv/pyenv) for managing Python versions.
   - [Poetry](https://python-poetry.org/) for dependency management.

2. **Clone the repository:**
   ```bash
   git clone https://github.com/CthtufsPetProjects/cloud-function-gen2-template.git
   ```

3. **Navigate to the project directory:**
   ```bash
   cd cloud-function-gen2-template
   ```

4. **Install dependencies:**
   ```bash
   poetry install
   ```

5. **Activate pre-commit hooks:**
   ```bash
   make install_hooks
   ```

---

## CI Setup

To enable CI/CD pipelines, follow these steps:

1. Add the following secrets to your GitHub Actions:
   - **GCP_PROJECT_ID** – Your Google Cloud project ID.
   - **GCP_REGION** – The Google Cloud region where the functions will be deployed.
   - **GCP_SA_KEY** – Service Account key JSON (must be created manually in Google Cloud [Service Accounts](https://cloud.google.com/iam/docs/keys-create-delete#creating)).

2. For test coverage metrics:
   - Register your project on [Codecov](https://app.codecov.io/).
   - Obtain the **CODECOV_TOKEN** for your project and add it to GitHub secrets.
   - Add the environment variable `INSIDE_CI=1` to your GitHub Actions secrets.

---

## Usage

1. Fill variables in the `terraform.tfvars` file.
   ```bash
   cp terraform.tfvars.template terraform.tfvars
   ```
1. Deploy the infrastructure:
   ```bash
   terraform init
   terraform apply
   ```
1. Setup CI (see the [CI Setup](#ci-setup) section).
1. Commit changes and push to your repository.

   *Note*: I suggest to keep terraform state in the repository for simplicity. For production, use a remote state.
1. Create PR and check PR status.
1. Merge PR to the `main` branch.
1. Check the GitHub Actions tab for the CI/CD pipeline status.


*Note:* **After the first deployment**, you might need to run `terraform apply` again to properly configure Cloud Scheduler roles.

---

## Contribution

Community contributions warmly welcomed! Please create pull requests or open issues to discuss suggestions and improvements.

---

## License

This project is distributed under the MIT License. See the [LICENSE](LICENSE) file for details.
