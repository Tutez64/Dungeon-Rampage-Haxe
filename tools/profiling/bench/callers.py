import sys,collections,re
path=sys.argv[1]; targets=sys.argv[2:]
stacks=[]; cur=None
for line in open(path,errors='replace'):
    if not line.strip():
        if cur is not None: stacks.append(cur); cur=None
        continue
    if not line.startswith((' ','\t')):
        cur=[]
        continue
    if cur is not None: cur.append(line.strip().split(' ',1)[1] if ' ' in line.strip() else line.strip())
if cur: stacks.append(cur)
n=len(stacks)
print('samples',n)
def short(s):
    s=re.sub(r'\(.*','',s); s=s.replace('_obj::','.').replace('::','.')
    return s[-70:]
for t in targets:
    callers=collections.Counter(); tot=0
    for st in stacks:
        if st and t in st[0]:
            tot+=1
            callers[short(st[1]) if len(st)>1 else '?']+=1
    print('== %s : self %.2f%% of main thread'%(t,100.0*tot/n))
    for c,k in callers.most_common(9): print('    %5.2f%%  %s'%(100.0*k/n,c))
