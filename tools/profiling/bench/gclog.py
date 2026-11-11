import sys,re,collections
run=sys.argv[1]
ev=[]
for l in open(run+'/events.log'):
    a,b=l.rstrip('\n').split(' ',1)
    try: ev.append((float(a),b))
    except: pass
gl=[]
for l in open(run+'/game.log',errors='replace'):
    if l.startswith('GCLOG'):
        d=dict(kv.split('=',1) for kv in l.split()[1:])
        gl.append(d)
# align: first forced major collection <-> first 'gc used' note
t_ev=[t for t,b in ev if b.startswith('gc used')][0]
t_gc=[float(d['t'])+float(d['ms'])/1000 for d in gl if d['major']=='1'][0]
off=t_gc-t_ev
phases=[(t,b.split()[1]) for t,b in ev if b.startswith('step phase:') or b.startswith('step ')]
steps=[(t,b[5:].split(' ')[0]) for t,b in ev if b.startswith('step ')]
def step_at(t):
    cur=''
    for ts,s in steps:
        if ts<=t: cur=s
        else: break
    return cur
verbose='-v' in sys.argv
agg=collections.OrderedDict()
for d in gl:
    t=float(d['t'])-off
    st=step_at(t)
    kind=d['mark']
    if d['major']=='1': kind='forced'
    key=(st.split(':')[0]+':'+(st.split(':')[1] if ':' in st else ''),kind,d['why'])
    a=agg.setdefault(key,[]); a.append(float(d['ms']))
    if verbose or (kind not in('minor','forced')):
        print('%7.2f %-16s %-10s why=%-6s mode=%s ms=%5.1f mark=%5.1f rows=%s blocks=%s large=%s since=%s/%s space=%s est=%s filled=%s after=%s next=%s'%(t,st[:16],kind,d['why'],d['mode'],float(d['ms']),float(d['markMs']),d['rowsMB'],d['blocksMB'],d['largeMB'],d['largeSinceMB'],d['budgetMB'],d['largeSpaceMB'],d['est'],d['filled'],d['after'],d['next']))
print()
for k,v in agg.items():
    print('%-18s %-10s %-6s n=%3d  ms avg %5.1f max %5.1f'%(k[0],k[1],k[2],len(v),sum(v)/len(v),max(v)))
