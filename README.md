# fluent-plugin-script_append

change from https://github.com/udzura/fluent-plugin-script_append。

# Installation
```
cp out_script_append.rb /etc/td-agent/plugin/
```
# usage
```
<source>
  type tail
  path /tmp/a.log
  format /^(?<client_ip>[^ ]*) \[(?<time>[^\]]*)\]$/
  time_format %d/%b/%Y:%H:%M:%S %z
  pos_file /tmp/t.pos
  tag tt
</source>

<match tt.**>
  type script_append
  language shell
  run_script "sh /tmp/a.sh"
  lookup_key client_ip
  add_key ipwhere
  tag new
</match>

<match new.**>
  type file
  path /tmp/out.log
</match>
```
```
##tmp.sh
echo "start $1 end"
```
# testing
## input
```
127.0.0.1 [19/Oct/2015:15:16:22 +0800]
```
## output
```
2015-10-19T15:16:22+08:00       new     {"client_ip":"127.0.0.1","ipwhere":"start 127.0.0.1 end\n"}
```
