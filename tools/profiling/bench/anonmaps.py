#!/usr/bin/env python3
import sys,re,collections
pid=sys.argv[1]
cur=None; maps=[]
for l in open(f'/proc/{pid}/smaps'):
    m=re.match(r'^([0-9a-f]+)-([0-9a-f]+) (\S+) \S+ \S+ \S+\s*(.*)$',l)
    if m:
        cur={'name':m.group(4),'perm':m.group(3),'size':(int(m.group(2),16)-int(m.group(1),16))//1024,'Rss':0}
        maps.append(cur)
    else:
        k,_,v=l.partition(':')
        if cur is not None and k=='Rss': cur[k]=int(v.split()[0])
an=[m for m in maps if m['name']=='' and m['size']>=1024]
h=collections.Counter(); hr=collections.Counter()
for m in an:
    k=round(m['size']/1024,1)
    h[k]+=1; hr[k]+=m['Rss']
print('anon maps >=1M: n=%d size=%.0f rss=%.0f MiB'%(len(an),sum(m['size'] for m in an)/1024,sum(m['Rss'] for m in an)/1024))
for k,v in sorted(h.items(), key=lambda x:-hr[x[0]])[:30]:
    print('  size %7.1f MiB x%-3d rss %7.1f MiB'%(k,v,hr[k]/1024))
