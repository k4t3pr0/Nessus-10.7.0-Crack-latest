# Nessus-10.6.4-202401292356
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
