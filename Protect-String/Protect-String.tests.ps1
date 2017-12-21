#region Pester Module
ipmo (`
    Get-Item (`
        [System.IO.Path]::GetFullPath((`
            Join-Path $PSScriptRoot '../../Vendor/Pester')`
        )`
    )`
)
#endregion Pester Module

#region Import Test Module
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.tests\.ps1', '.psd1'
ipmo "$here\$sut" -Force
#endregion Import Test Module

Describe 'Tests' {

    Context 'ConvertTo-Hash' {
        It 'Should hash a string' {
            ConvertTo-Hash -String 'Michael' | Should BeExactly 'b2edbb9bef87a5568deb03f27e36f25d313b2c399f2c1682ac28dd92342f6b73'
        }
        It 'Should hash a string with a custom salt' {
            ConvertTo-Hash -String 'Michael' -salt 'salty' | Should BeExactly 'e4ceb675efeb36ffced50b6a2e88050c4c10d44dc1a5b6033ac0596fa0fef546'
        }
        It 'Should hash using MD5' {
            ConvertTo-Hash -String Michael -HashName MD5 | Should BeExactly '41c90eb9ceb69bddb5d100f263371f53'
        }
        It 'Should hash using RIPEMD160' {
            ConvertTo-Hash -String Michael -HashName RIPEMD160 | Should BeExactly 'fb45d2ac3eb3bf50e2629f8e189577e14ab54400'
        }
        It 'Should hash using SHA1' {
            ConvertTo-Hash -String Michael -HashName SHA1 | Should BeExactly 'f4b84f060039c81921e164aac1bd854ad52ffa8a'
        }
        It 'Should hash using SHA256' {
            ConvertTo-Hash -String Michael -HashName SHA256 | Should BeExactly 'b2edbb9bef87a5568deb03f27e36f25d313b2c399f2c1682ac28dd92342f6b73'
        }
        It 'Should hash using SHA384' {
            ConvertTo-Hash -String Michael -HashName SHA384 | Should BeExactly '3ac0dd094bcefa3cfeba6c6f1db0f8860f67a252f38d38dd36ffa454a4ae39a741d0437f4eeabd9c2767a4efda4eecff'
        }
        It 'Should hash using SHA512' {
            ConvertTo-Hash -String Michael -HashName SHA512 | Should BeExactly 'f02f59fa36e32c8944a60949c50cde8e87d6427cf33e89cef1c5013213107af7c45171d6cdc14e0568293e1db0bdb50e875493cda960376dc546ddf436f30253'
        }
    }

    Context 'Get-AesKey' {
        It 'Should create a random AES key' {
            {Get-AesKey} | Should Not Throw 
        }

        It 'Should create a AES key from a string' {
            Get-AesKey -key 'My Secret' | Should BeExactly 'ZWY4NWFlZWZlMmIzZDkwZDQ2OGExYmJiNjc0ZWMzMDM='
        }
    }

    Context 'Protect-String and Unprotect-Strinct' {
        $Key = Get-AesKey -key 'My Secret'
        $Text = 'Please protect me!!!'
        $CipherText = Protect-String -String $Text -Key $Key
        
        It 'Should encrypt a string' {
            $CipherText | Should Not Be $Text
        }

        It 'Should decrypt a string' {
            Unprotect-String -CipherText $CipherText -Key $Key | Should BeExactly $Text
        }
    }

}

Remove-Module -name "$($sut -replace '.psd1', '')"