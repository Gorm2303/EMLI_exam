#!/usr/bin/python3
#located at /usr/lib/cgi-bin/sync_time.py
import cgi
import os

print("Content-Type: text/html\n")

# Retrieve time from POST data
form = cgi.FieldStorage()
new_time = form.getvalue('time')

# Update system time
if new_time:
    command = f'sudo date -s "{new_time}"'
    os.system(command)
    print("<html><body><h1>Time Updated</h1></body></html>")
else:
    print("<html><body><h1>Error: No time provided</h1></body></html>")
