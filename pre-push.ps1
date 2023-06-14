Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()


    Write-Output "You must verify your identity before pushing!"

    # Popup for username, password and company id
	$form = New-Object System.Windows.Forms.Form 
	$form.Text = "Authentication Required"
	$form.Size = New-Object System.Drawing.Size(300,260) 
	$form.StartPosition = "CenterScreen"
	$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
	$form.MaximizeBox = $False
	
    # Company ID label and field
    $compLabel = New-Object System.Windows.Forms.Label
    $compLabel.Location = New-Object System.Drawing.Point(10,20) 
    $compLabel.Size = New-Object System.Drawing.Size(280,20) 
    $compLabel.Text = "Company ID:"
    $form.Controls.Add($compLabel)

	$compBox = New-Object System.Windows.Forms.TextBox 
	$compBox.Location = New-Object System.Drawing.Point(10,40) 
	$compBox.Size = New-Object System.Drawing.Size(260,20) 
	$compBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
	$form.Controls.Add($compBox) 
	
    # Username label and field
    $userLabel = New-Object System.Windows.Forms.Label
    $userLabel.Location = New-Object System.Drawing.Point(10,70) 
    $userLabel.Size = New-Object System.Drawing.Size(280,20) 
    $userLabel.Text = "Email:"
    $form.Controls.Add($userLabel)

	$userBox = New-Object System.Windows.Forms.TextBox 
	$userBox.Location = New-Object System.Drawing.Point(10,90) 
	$userBox.Size = New-Object System.Drawing.Size(260,20) 
	$userBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
	$form.Controls.Add($userBox)

    # Password label and field
    $passLabel = New-Object System.Windows.Forms.Label
    $passLabel.Location = New-Object System.Drawing.Point(10,120) 
    $passLabel.Size = New-Object System.Drawing.Size(280,20) 
    $passLabel.Text = "Password:"
    $form.Controls.Add($passLabel)

	$passBox = New-Object System.Windows.Forms.TextBox 
	$passBox.Location = New-Object System.Drawing.Point(10,140) 
	$passBox.Size = New-Object System.Drawing.Size(260,20)
	$passBox.UseSystemPasswordChar = $True
	$passBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
	$form.Controls.Add($passBox)



    # OK button
    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Point(75,180)
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = "OK"
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $OKButton
    $form.Controls.Add($OKButton)

    # Cancel button
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(150,180)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = "Cancel"
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)


    $form.Topmost = $true

    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $username = $userBox.Text
        $password = $passBox.Text
        $companyId = $compBox.Text # Company ID from the form
        $password = $passBox.Text

        # Construct the POST data
        $postParams = @{
            "accountId" = $companyId
            "email" = $username
            "password" = $password
        }

        # Convert to JSON
        $jsonBody = ConvertTo-Json $postParams

        # Perform the POST request
        try {
            $response = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/verify-hook' -Method POST -Body $jsonBody -ContentType 'application/json'
	if ($response.requireOTP)
	{	
    # Create another form for OTP input
    $otpForm = New-Object System.Windows.Forms.Form
    $otpForm.Text = "Enter One Time Password"
    $otpForm.Size = New-Object System.Drawing.Size(300,120)
    $otpForm.StartPosition = "CenterScreen"
    $otpForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $otpForm.MaximizeBox = $False

    # OTP input
    $otpBox = New-Object System.Windows.Forms.TextBox
    $otpBox.Location = New-Object System.Drawing.Point(10,20)
    $otpBox.Size = New-Object System.Drawing.Size(260,20)
    $otpBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $otpForm.Controls.Add($otpBox)

    # OK button for the OTP form
    $otpOKButton = New-Object System.Windows.Forms.Button
    $otpOKButton.Location = New-Object System.Drawing.Point(100,50)
    $otpOKButton.Size = New-Object System.Drawing.Size(75,23)
    $otpOKButton.Text = "OK"
    $otpOKButton.Add_Click({ 
        $otpForm.Tag = $otpBox.Text
        $otpForm.Close()
    })
    $otpForm.Controls.Add($otpOKButton)

    # Show the OTP form and wait for the user to input the OTP
    $otpForm.ShowDialog()

    # Get the OTP from the form
    $otp = $otpForm.Tag

    # Now, you can send this OTP to your server and check if it's correct
    $otpJson = @{
		email = $username
        otp = $otp
    } | ConvertTo-Json

    $otpResponse = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/verify-hook-otp' -Method POST -Body $otpJson -ContentType 'application/json'
    if ($otpResponse.code -eq 0) {
		Write-Output "Verified OTP"
    } else {
        # If the OTP is incorrect, stop the push
        Write-Output "Incorrect OTP!"
        exit 1
    }
	}

			Write-Output "Successfully authenticated with CodeLock!"
        } catch {
            # If the credentials are incorrect, stop the push
            Write-Output "Incorrect username, password, or company ID!"
            exit 1
        }
    } else {
        Write-Output "Authentication cancelled!"
        exit 1
    }
	


# If the user is verified, or if they just verified themselves, allow the push to go through
exit 0
