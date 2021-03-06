#
# Copyright 2019, Benjamin Perrier <ben dot perrier at outlook dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

<#
        .SYNOPSIS
        ResizePic resize pictures.

        .DESCRIPTION
        Select pictures, select the number of time you want to dicrease the size, then click on resize.     
        ResizePic automatically creates a folder where your original images are and places all the resized pictures.

        .NOTES
        Version:    1.0
        Author:     <Benjamin PERRIER>
        Creation Date:  <23/02/2019>
        Script Name: ResizePic

    #>

$script:resizeclick = 1
function get-metric {
    $sum = 0
    foreach ($a in $arr) { 
        $sum = $sum + $a
    }

    $size = "$sum"
    $sizearr = $size.ToCharArray()

    if ($sizearr.count -gt 6) {
        $metric = "MB"
    }
    else {$metric = "KB"}

    $res = $size / "1$metric"

    $res = [math]::Round($res)
    $res = "$res $metric"
    $res
}

Function Set-ImageSize {

    [CmdletBinding(
        SupportsShouldProcess = $True,
        ConfirmImpact = "Low"
    )]		
    Param
    (
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [Alias("Image")]	
        [String[]]$FullName,
        [String]$Destination = $(Get-Location),
        [Switch]$Overwrite,
        [Int]$WidthPx,
        [Int]$HeightPx,
        [Int]$DPIWidth,
        [Int]$DPIHeight,
        [Switch]$FixedSize,
        [Switch]$RemoveSource
    )

    Begin {
        [void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
    }
	
    Process {

        Foreach ($ImageFile in $FullName) {
            If (Test-Path $ImageFile) {
                $OldImage = new-object System.Drawing.Bitmap $ImageFile
                $OldWidth = $OldImage.Width
                $OldHeight = $OldImage.Height
				
                if ($WidthPx -eq $Null) {
                    $WidthPx = $OldWidth
                }
                if ($HeightPx -eq $Null) {
                    $HeightPx = $OldHeight
                }
				
                if ($FixedSize) {
                    $NewWidth = $WidthPx
                    $NewHeight = $HeightPx
                }
                else {
                    if ($OldWidth -lt $OldHeight) {
                        $NewWidth = $WidthPx
                        [int]$NewHeight = [Math]::Round(($NewWidth * $OldHeight) / $OldWidth)
						
                        if ($NewHeight -gt $HeightPx) {
                            $NewHeight = $HeightPx
                            [int]$NewWidth = [Math]::Round(($NewHeight * $OldWidth) / $OldHeight)
                        }
                    }
                    else {
                        $NewHeight = $HeightPx
                        [int]$NewWidth = [Math]::Round(($NewHeight * $OldWidth) / $OldHeight)
						
                        if ($NewWidth -gt $WidthPx) {
                            $NewWidth = $WidthPx
                            [int]$NewHeight = [Math]::Round(($NewWidth * $OldHeight) / $OldWidth)
                        }						
                    }
                }

                $ImageProperty = Get-ItemProperty $ImageFile				
                $SaveLocation = Join-Path -Path $Destination -ChildPath ($ImageProperty.Name)

                If (!$Overwrite) {
                    If (Test-Path $SaveLocation) {
                        $Title = "A file already exists: $SaveLocation"
							
                        $ChoiceOverwrite = New-Object System.Management.Automation.Host.ChoiceDescription "&Overwrite"
                        $ChoiceCancel = New-Object System.Management.Automation.Host.ChoiceDescription "&Cancel"
                        $Options = [System.Management.Automation.Host.ChoiceDescription[]]($ChoiceCancel, $ChoiceOverwrite)		
                        If (($host.ui.PromptForChoice($Title, $null, $Options, 1)) -eq 0) {
                            Write-Verbose "Image '$ImageFile' exist in destination location - skiped"
                            Continue
                        }
                    }
                }
				
                $NewImage = new-object System.Drawing.Bitmap $NewWidth, $NewHeight

                $Graphics = [System.Drawing.Graphics]::FromImage($NewImage)
                $Graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $Graphics.DrawImage($OldImage, 0, 0, $NewWidth, $NewHeight) 

                $ImageFormat = $OldImage.RawFormat
                $OldImage.Dispose()
                if ($DPIWidth -and $DPIHeight) {
                    $NewImage.SetResolution($DPIWidth, $DPIHeight)
                }
				
                $NewImage.Save($SaveLocation, $ImageFormat)
                $NewImage.Dispose()
                Write-Verbose "Image '$ImageFile' was resize from $($OldWidth)x$($OldHeight) to $($NewWidth)x$($NewHeight) and save in '$SaveLocation'"
				
                If ($RemoveSource) {
                    Remove-Item $Image -Force
                    Write-Verbose "Image source '$ImageFile' was removed"
                }
            }
        }

    }
	
    End {}
}

function ResizePic {


    #region Import the Assemblies
    [reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
    [reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
    #endregion

    #region Generated Form Objects
    $form1 = New-Object System.Windows.Forms.Form
    $progressBar1 = New-Object System.Windows.Forms.ProgressBar
    $button3 = New-Object System.Windows.Forms.Button
    $button2 = New-Object System.Windows.Forms.Button
    $groupBox2 = New-Object System.Windows.Forms.GroupBox
    $radioButton4 = New-Object System.Windows.Forms.RadioButton
    $radioButton3 = New-Object System.Windows.Forms.RadioButton
    $radioButton2 = New-Object System.Windows.Forms.RadioButton
    $radioButton1 = New-Object System.Windows.Forms.RadioButton
    $groupBox1 = New-Object System.Windows.Forms.GroupBox
    $label2 = New-Object System.Windows.Forms.Label
    $label1 = New-Object System.Windows.Forms.Label
    $textBox2 = New-Object System.Windows.Forms.TextBox
    $textBox1 = New-Object System.Windows.Forms.TextBox
    $button1 = New-Object System.Windows.Forms.Button
    $InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
    #endregion Generated Form Objects

    #Provide Custom Code for events specified in PrimalForms.
    $button3_OnClick = 
    {
        #QUITTER
        $form1.Close();
    }

    $button1_OnClick = 
    {
        #PARCOURIR
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Multiselect = $true # Multiple files can be chosen
            Filter      = 'Images (*.bmp, *.gif, *.jpg, *.jpeg, *.png, *.tif)|*.bmp;*.gif;*.jpg;*.jpeg;*.png;*.tif' # Specified file types
        }

        [void]$FileBrowser.ShowDialog()

        $script:path = $FileBrowser.FileNames



        If ($FileBrowser.FileNames -like "*\*") {

            $script:totalimage = $FileBrowser.FileNames.Count
            $arr = @()
            foreach ($p in $path) {
                $arr += (Get-Item $p).length 
            }

            $tailleimage = get-metric

            $script:resizeclick = 0


        }

        #TOTAL IMAGE
        $textBox1.Text = $script:totalimage
        #TAILLE IMAGE
        $textBox2.Text = $tailleimage

    }

    $button2_OnClick = 
    {
        #RESIZE
        if ($script:resizeclick -eq 0) {
            # Check the current state of each radio button and respond accordingly
            if ($RadioButton1.Checked) {
                $sizechecked = 1.5
            }
            elseif ($RadioButton3.Checked) {
                $sizechecked = 2
            }
            elseif ($RadioButton2.Checked) {
                $sizechecked = 4
            }
            elseif ($RadioButton4.Checked = $true) {
                $sizechecked = 8
            }
                
            $indexpicture = 1
            if ($script:totalimage -gt 110) {
                $indexpicture = $script:totalimage / 100
                $indexpicture = [math]::Round($indexpicture)
                $valueplusprogress = 1
            }
            else {
                $valueplusprogress = 100 / $script:totalimage

            }
       
            $pictureslist = $script:path
                    
            $splitpath = Split-Path -Path $pictureslist[0]
            
            $name = Get-Date -UFormat "ResizePic_%d.%m.%Y-%H.%M.%S"
            $path = "$splitpath\"
            $pathname = "$path$name"
            New-Item -ItemType directory -Path $pathname    
            
            $progressBar1.Value = '0'
            $indexcount = 0
            foreach ($p in $pictureslist) {
                $OldImage = new-object System.Drawing.Bitmap $p
                $OldWidth = $OldImage.Width
                $OldHeight = $OldImage.Height
                       
                $newWidth = $OldWidth / $sizechecked
                $newHeight = $OldHeight / $sizechecked
            
                $p | Set-ImageSize -Destination $pathname -WidthPx $newWidth -HeightPx $newHeight
                
                if ($indexpicture -eq $indexcount) {
                    if ($progressBar1.Value -lt 100) {
                        $progressBar1.Value = $progressBar1.Value + $valueplusprogress
                    }
                    $indexcount = 0
                }
                $indexcount++
            }
    
            $progressBar1.Value = '100'

            Add-Type -AssemblyName System.Windows.Forms
            $msg = "Resize terminé"
            $result = [System.Windows.Forms.MessageBox]::Show($msg, "ResizePic")
        }
        else {

            Add-Type -AssemblyName System.Windows.Forms
            $msg = "Il faut selectionner au moins une image"
            $result = [System.Windows.Forms.MessageBox]::Show($msg, "ResizePic")

        }
    }

    $OnLoadForm_StateCorrection =
    {
        $form1.WindowState = $InitialFormWindowState
    }

    #region Generated Form Code
    $form1.BackColor = [System.Drawing.Color]::FromArgb(255, 153, 180, 209)
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 361
    $System_Drawing_Size.Width = 484
    $form1.ClientSize = $System_Drawing_Size
    $form1.DataBindings.DefaultDataSourceUpdateMode = 0
    $form1.Name = "form1"
    $form1.Text = "ResizePic"


    $progressBar1.DataBindings.DefaultDataSourceUpdateMode = 0
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 13
    $System_Drawing_Point.Y = 262
    $progressBar1.Location = $System_Drawing_Point
    $progressBar1.Name = "progressBar1"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 23
    $System_Drawing_Size.Width = 459
    $progressBar1.Size = $System_Drawing_Size
    $progressBar1.TabIndex = 5

    $form1.Controls.Add($progressBar1)


    $button3.DataBindings.DefaultDataSourceUpdateMode = 0

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 255
    $System_Drawing_Point.Y = 299
    $button3.Location = $System_Drawing_Point
    $button3.Name = "button3"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 50
    $System_Drawing_Size.Width = 205
    $button3.Size = $System_Drawing_Size
    $button3.TabIndex = 4
    $button3.Text = "Quitter"
    $button3.UseVisualStyleBackColor = $True
    $button3.add_Click($button3_OnClick)

    $form1.Controls.Add($button3)


    $button2.DataBindings.DefaultDataSourceUpdateMode = 0

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 25
    $System_Drawing_Point.Y = 299
    $button2.Location = $System_Drawing_Point
    $button2.Name = "button2"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 50
    $System_Drawing_Size.Width = 205
    $button2.Size = $System_Drawing_Size
    $button2.TabIndex = 3
    $button2.Text = "Resize !"
    $button2.UseVisualStyleBackColor = $True
    $button2.add_Click($button2_OnClick)

    $form1.Controls.Add($button2)

    $groupBox2.BackColor = [System.Drawing.Color]::FromArgb(255, 185, 209, 234)

    $groupBox2.DataBindings.DefaultDataSourceUpdateMode = 0
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 13
    $System_Drawing_Point.Y = 146
    $groupBox2.Location = $System_Drawing_Point
    $groupBox2.Name = "groupBox2"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 101
    $System_Drawing_Size.Width = 459
    $groupBox2.Size = $System_Drawing_Size
    $groupBox2.TabIndex = 1
    $groupBox2.TabStop = $False
    $groupBox2.Text = "Selectionnez la taille de réduction : "

    $form1.Controls.Add($groupBox2)

    $radioButton4.DataBindings.DefaultDataSourceUpdateMode = 0

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 286
    $System_Drawing_Point.Y = 64
    $radioButton4.Location = $System_Drawing_Point
    $radioButton4.Name = "radioButton4"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 24
    $System_Drawing_Size.Width = 104
    $radioButton4.Size = $System_Drawing_Size
    $radioButton4.TabIndex = 3
    $radioButton4.TabStop = $True
    $radioButton4.Text = "8 fois"
    $radioButton4.UseVisualStyleBackColor = $True

    $groupBox2.Controls.Add($radioButton4)


    $radioButton3.DataBindings.DefaultDataSourceUpdateMode = 0

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 68
    $System_Drawing_Point.Y = 62
    $radioButton3.Location = $System_Drawing_Point
    $radioButton3.Name = "radioButton3"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 24
    $System_Drawing_Size.Width = 104
    $radioButton3.Size = $System_Drawing_Size
    $radioButton3.TabIndex = 2
    $radioButton3.TabStop = $True
    $radioButton3.Text = "2 fois"
    $radioButton3.UseVisualStyleBackColor = $True

    $groupBox2.Controls.Add($radioButton3)


    $radioButton2.DataBindings.DefaultDataSourceUpdateMode = 0

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 285
    $System_Drawing_Point.Y = 26
    $radioButton2.Location = $System_Drawing_Point
    $radioButton2.Name = "radioButton2"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 24
    $System_Drawing_Size.Width = 104
    $radioButton2.Size = $System_Drawing_Size
    $radioButton2.TabIndex = 1
    $radioButton2.TabStop = $True
    $radioButton2.Text = "4 fois"
    $radioButton2.UseVisualStyleBackColor = $True

    $groupBox2.Controls.Add($radioButton2)


    $radioButton1.DataBindings.DefaultDataSourceUpdateMode = 0

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 70
    $System_Drawing_Point.Y = 27
    $radioButton1.Location = $System_Drawing_Point
    $radioButton1.Name = "radioButton1"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 24
    $System_Drawing_Size.Width = 104
    $radioButton1.Size = $System_Drawing_Size
    $radioButton1.TabIndex = 0
    $radioButton1.TabStop = $True
    $radioButton1.Text = "1,5 fois"
    $radioButton1.UseVisualStyleBackColor = $True
    $RadioButton1.Checked = $True

    $groupBox2.Controls.Add($radioButton1)


    $groupBox1.BackColor = [System.Drawing.Color]::FromArgb(255, 185, 209, 234)

    $groupBox1.DataBindings.DefaultDataSourceUpdateMode = 0
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 12
    $System_Drawing_Point.Y = 19
    $groupBox1.Location = $System_Drawing_Point
    $groupBox1.Name = "groupBox1"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 108
    $System_Drawing_Size.Width = 460
    $groupBox1.Size = $System_Drawing_Size
    $groupBox1.TabIndex = 0
    $groupBox1.TabStop = $False
    $groupBox1.Text = "Selectionnez les images à redimentionner :"

    $form1.Controls.Add($groupBox1)
    $label2.DataBindings.DefaultDataSourceUpdateMode = 0

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 316
    $System_Drawing_Point.Y = 30
    $label2.Location = $System_Drawing_Point
    $label2.Name = "label2"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 15
    $System_Drawing_Size.Width = 100
    $label2.Size = $System_Drawing_Size
    $label2.TabIndex = 4
    $label2.Text = "Taille Image :"

    $groupBox1.Controls.Add($label2)

    $label1.DataBindings.DefaultDataSourceUpdateMode = 0

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 183
    $System_Drawing_Point.Y = 30
    $label1.Location = $System_Drawing_Point
    $label1.Name = "label1"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 15
    $System_Drawing_Size.Width = 100
    $label1.Size = $System_Drawing_Size
    $label1.TabIndex = 3
    $label1.Text = "Total Image :"

    $groupBox1.Controls.Add($label1)

    $textBox2.DataBindings.DefaultDataSourceUpdateMode = 0
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 316
    $System_Drawing_Point.Y = 46
    $textBox2.Location = $System_Drawing_Point
    $textBox2.Name = "textBox2"
    $textBox2.ReadOnly = $True
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 20
    $System_Drawing_Size.Width = 100
    $textBox2.Size = $System_Drawing_Size
    $textBox2.TabIndex = 2

    $groupBox1.Controls.Add($textBox2)

    $textBox1.DataBindings.DefaultDataSourceUpdateMode = 0
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 183
    $System_Drawing_Point.Y = 46
    $textBox1.Location = $System_Drawing_Point
    $textBox1.Name = "textBox1"
    $textBox1.ReadOnly = $True
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 20
    $System_Drawing_Size.Width = 100
    $textBox1.Size = $System_Drawing_Size
    $textBox1.TabIndex = 1

    $groupBox1.Controls.Add($textBox1)


    $button1.DataBindings.DefaultDataSourceUpdateMode = 0

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 13
    $System_Drawing_Point.Y = 33
    $button1.Location = $System_Drawing_Point
    $button1.Name = "button1"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 50
    $System_Drawing_Size.Width = 126
    $button1.Size = $System_Drawing_Size
    $button1.TabIndex = 0
    $button1.Text = "Parcourir"
    $button1.UseVisualStyleBackColor = $True
    $button1.add_Click($button1_OnClick)

    $groupBox1.Controls.Add($button1)
    #endregion Generated Form Code

    #Save the initial state of the form
    $InitialFormWindowState = $form1.WindowState
    #Init the OnLoad event to correct the initial state of the form
    $form1.add_Load($OnLoadForm_StateCorrection)
    #Show the Form
    $form1.ShowDialog()| Out-Null

} #End Function

ResizePic