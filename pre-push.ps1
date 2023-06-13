Add-Type -AssemblyName System.Windows.Forms

# Get the current user's Documents directory
$auth_file = [Environment]::GetFolderPath("MyDocuments") + "\auth_file.txt"

# Check if the user is verified
if (!(Test-Path $auth_file)) {
    Write-Output "You must verify your identity before pushing!"

    # Popup for username and password
    $form = New-Object System.Windows.Forms.Form 
    $form.Text = "CodeLock Authentication"
    $form.Size = New-Object System.Drawing.Size(300,200) 
    $form.StartPosition = "CenterScreen"

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Point(75,120)
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = "OK"
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $OKButton
    $form.Controls.Add($OKButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(150,120)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = "Cancel"
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20) 
    $label.Size = New-Object System.Drawing.Size(280,20) 
    $label.Text = "Please enter your username and password:"
    $form.Controls.Add($label) 

    $userBox = New-Object System.Windows.Forms.TextBox 
    $userBox.Location = New-Object System.Drawing.Point(10,40) 
    $userBox.Size = New-Object System.Drawing.Size(260,20) 
    $form.Controls.Add($userBox) 

    $passBox = New-Object System.Windows.Forms.TextBox 
    $passBox.Location = New-Object System.Drawing.Point(10,80) 
    $passBox.Size = New-Object System.Drawing.Size(260,20)
    $passBox.UseSystemPasswordChar = $True
    $form.Controls.Add($passBox) 

    $form.Topmost = $true

    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $username = $userBox.Text
        $password = $passBox.Text
        # Convert the password to a SecureString
        $securePassword = ConvertTo-SecureString $password -AsPlainText -Force

        # Validate the credentials
        # This is just an example; your validation logic might be different
        $correct_username = "correct_username"
        $correct_password = ConvertTo-SecureString "correct_password" -AsPlainText -Force
        if (($username -eq $correct_username) -and ($securePassword -eq $correct_password)) {
            # If the credentials are correct, mark the user as verified
            New-Item -ItemType file -Path $auth_file -Force | Out-Null
        } else {
            # If the credentials are incorrect, stop the push
            Write-Output "Incorrect username or password!"
            exit 1
        }
    } else {
        Write-Output "Authentication cancelled!"
        exit 1
    }
}

# If the user is verified, or if they just verified themselves, allow the push to go through
exit 0
