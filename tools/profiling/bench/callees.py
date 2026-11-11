import sys,collections,re
path=sys.argv[1]; depth=int(sys.argv[2]); targets=sys.argv[3:]
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
    return s[-75:]
for t in targets:
    tot=0; callees=collections.Counter()
    for st in stacks:
        idx=[i for i,f in enumerate(st) if t in f]
        if not idx: continue
        i=idx[-1]  # outermost occurrence
        tot+=1
        j=i-depth
        callees[short(st[j]) if j>=0 else '(self or shallower)']+=1
    print('== %s : %.2f%% of main thread (inclusive)'%(t,100.0*tot/n))
    for c,k in callees.most_common(14): print('    %5.2f%%  %s'%(100.0*k/n,c))
