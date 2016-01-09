# recon

A small swift script that monitors wifi and resets the connection if lost, for unreliable routers.

Code is commented and should be self explanatory.

It has no external dependencies.

## You can run it doing:

```bash
swift recon/main.swift
```

or archive it with xcode to get a binary.

you may need to run it with "sudo" if you experience problems.

## Behavior

The script fetches a known web page (google.com by default), if something fails it will turn down the wifi interface and turn it on back again.

## Motivator

With unreliable internet providers and/or bad routers the internet connection may timeout after a couple minutes of usage, restarting the wifi interface seems to solve it. I got tired of doing it manually.

## Output

The script output is very simple

. pinging server
\# connection error, will reconnect
! reconnection error


