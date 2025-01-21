# action-dashcam
GitHub actions for TestDriver Dashcam service

# Usage

First step must be to install the Dashcam CLI/GUI on the runner. The GUI is required for the CLI to function correctly.
```yaml
  - name: Install Dashcam
    id: install_dashcam
    continue-on-error: true # Optional
    uses: thebrowsercompany/action-dashcam@<VERSION_TAG>
    with:
        dashcam-version: "1.0.49" # See releases here: https://github.com/replayableio/replayable/releases
```

Right before the step that you want to record you need to Start the Dashcam.
```yaml
  - name: Start Dashcam
    id: start_dashcam
    if: ${{ steps.install_dashcam.outcome == 'success' }} # Only needed if continue-on-error is used on the install_dashcam
    continue-on-error: true
    uses: thebrowsercompany/action-dashcam/start@<VERSION_TAG>
    with:
      dashcam-api-key: ${{ secrets.DASHCAM_API_KEY }}
```

To stop the recording and upload the results use:
```yaml
  - name: Submit Dashcam recording
    if: ${{ always() && steps.start_dashcam.outcome == 'success' }}
    continue-on-error: true
    uses: thebrowsercompany/action-dashcam/stop@dev
    with:
        project-id: "507f1f77bcf86cd799439011" # The project-id value is the 'slug' component of the project URL on the Dashcam website.
```
