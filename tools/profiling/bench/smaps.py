#!/usr/bin/env python3
import sys,re,collections
pid=sys.argv[1]
cur=None; maps=[]
for l in open(f'/proc/{pid}/smaps'):
    m=re.match(r'^([0-9a-f]+)-([0-9a-f]+) (\S+) \S+ \S+ \S+\s*(.*)$',l)
    if m:
        cur={'name':m.group(4) or '[anon]','perm':m.group(3),'size':(int(m.group(2),16)-int(m.group(1),16))//1024,'Rss':0,'Private_Dirty':0,'Anonymous':0,'Pss':0}
        maps.append(cur)
    else:
        k,_,v=l.partition(':')
        if cur is not None and k in ('Rss','Private_Dirty','Anonymous','Pss'):
            cur[k]=int(v.split()[0])
agg=collections.defaultdict(lambda:[0,0,0,0])
for m in maps:
    n=m['name']
    if n=='[anon]':
        n='[anon >=64M map]' if m['size']>=65536 else ('[anon 1-64M map]' if m['size']>=1024 else '[anon small]')
    key=(n.split('/')[-1][:40], 'w' if 'w' in m['perm'] else 'r')
    a=agg[key]; a[0]+=m['Rss']; a[1]+=m['Anonymous']; a[2]+=m['size']; a[3]+=1
tot=sum(a[0] for a in agg.values()); tota=sum(a[1] for a in agg.values())
print(f'total rss {tot/1024:.0f} MiB anon {tota/1024:.0f} MiB')
for k,a in sorted(agg.items(), key=lambda x:-x[1][0])[:int(sys.argv[2]) if len(sys.argv)>2 else 14]:
    print(f'  {k[0]:42s} {k[1]} rss {a[0]/1024:7.1f}  anon {a[1]/1024:7.1f}  size {a[2]/1024:8.1f}  n={a[3]}')
