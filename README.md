# Nessus-10.7.0 Version 202401122041 ![Visitor](https://visitor-badge.laobi.icu/badge?page_id=k4t3pr0.Nessus-10.7.0-Crack-latest)
Nessus cracked version [Applicable to Ubuntu System]
- The operation method is the same as above.
- Download file: nessus_ubuntu.sh or directly copy the following code and save it as nessus_ubuntu.sh
## Uninstall method
- 【1】Stop the Nessus service.
```sh
sudo systemctl stop nessusd && systemctl --no-pager status nessusd
```
- 【2】Modify the /opt/nessus/ folder attributes
```sh
chattr -i -R /opt/nessus/
```
- 【3】Uninstall Nessus
```sh
apt remove nessus
```
## Precautions
- Problem: After the system or Nessus is restarted, the scan button may be temporarily unavailable.
- Reason: Nessus is reconfiguring the plug-in.
- Solution: Just wait patiently for 3 to 5 minutes.
