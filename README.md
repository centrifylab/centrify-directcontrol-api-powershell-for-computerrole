# Centrify Best Practices Seri = Computer Role Kullanımı İle Yetki Yönetimi

Bu script Rebuilt Architect Team tarafından Computer Role yöntemi kullanılarak computerlarda yetkilendirme yapılabilmesini sağlar.

## Fonkisyonlar:

### Add-Adgroup.ps1
Active Directory'de security grupları aşağıda verilen formatta oluşturur.

Computer Role için Computer Grup Formatı:
cfyC-[ZoneName]-[ServiceName]-[ServiceRoleName]

Computer Role için Login Role Active Directory Grup Formatı:
cfyU-[ZoneName]-[ServiceName]-[ServiceRoleName]-Login

Computer Role için Servis Role Active Directory Grup Formatı:
cfyU-[ZoneName]-[ServiceName]-[ServiceRoleName]

### Add-CentrifyComputerRole.ps1:
Computer Role tanımını yapar

### Add-CentrifyRole.ps1
Servis ve Uygulama tanımı için role oluşturur.

### Add-CentrifyRoleAsgtoComputerRole.ps1
Login ve Servis rolünü Active Directory Security grubu ile eşleştirir. 

### Add-ComputerToComputerRole
Computer objesini Computer Role'ün üyesi olarak ekler.

## Modüller:

### Get-DirectoryEntry

### New-Group

### Get-GroupDN

### Get-FQDN

### Get-ADInfo
