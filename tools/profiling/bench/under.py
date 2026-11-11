import sys,collections,re
path=sys.argv[1]; target=sys.argv[2]; top=int(sys.argv[3]) if len(sys.argv)>3 else 30
stacks=[]; cur=None
for line in open(path,errors='replace'):
    if not line.strip():
        if cur is not None: stacks.append(cur); cur=None
        continue
    if not line.startswith((' ','\t')):
        cur=[]; continue
    if cur is not None:
        t=line.strip(); cur.append(t.split(' ',1)[1] if ' ' in t else t)
if cur: stacks.append(cur)
n=len(stacks)
def short(s):
    s=re.sub(r'\(.*','',s); s=s.replace('_obj::','.').replace('::','.')
    return s[-80:]
incl=collections.Counter(); selfc=collections.Counter(); tot=0
for st in stacks:
    idx=[i for i,f in enumerate(st) if target in f]
    if not idx: continue
    tot+=1
    i=idx[-1]
    seen=set()
    for f in st[:i]:
        s=short(f)
        if s not in seen: incl[s]+=1; seen.add(s)
    selfc[short(st[0])]+=1
print('%s: %.2f%% of main thread'%(target,100.0*tot/n))
print('-- inclusive')
for c,k in incl.most_common(top): print('    %5.2f%%  %s'%(100.0*k/n,c))
print('-- self')
for c,k in selfc.most_common(top): print('    %5.2f%%  %s'%(100.0*k/n,c))
