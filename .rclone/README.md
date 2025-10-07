# Google Service Account Setup

This folder contains the rclone configuration for Google Drive access. To use this sync system, you need to set up a Google Service Account and place the credentials here.

## Steps to Get Your Service Account JSON

1. **Go to Google Cloud Console**: https://console.cloud.google.com/

2. **Create or Select a Project**: If you don't have one, create a new project.

3. **Enable the Google Drive API**:

   - Go to "APIs & Services" > "Library"
   - Search for "Google Drive API" and enable it

4. **Create a Service Account**:

   - Go to "IAM & Admin" > "Service Accounts"
   - Click "Create Service Account"
   - Give it a name (e.g., "asset-sync-service")
   - Grant it the "Editor" role for the project

5. **Create and Download the Key**:

   - Click on your new service account
   - Go to the "Keys" tab
   - Click "Add Key" > "Create new key" > JSON
   - The JSON file will download automatically

6. **Share the Google Drive Folder**:

   - The service account needs access to your Google Drive folder
   - Share the folder with the service account's email address (found in the JSON as "client_email")
   - Give it "Editor" access

7. **Place the JSON File Here**:
   - Rename the downloaded JSON file to `service-account.json`
   - Place it in this `.rclone/` folder
   - **Important**: Do NOT commit the real `service-account.json` to Git - it's gitignored for security

## Example

See `service-account.json.example` for the expected JSON structure (with fake data).

## Security Notes

- Never share your `service-account.json` file
- Each team member should get their own copy if needed
- The service account email in the JSON is what you share the Drive folder with
- If you lose access, you can create a new key from the Cloud Console
