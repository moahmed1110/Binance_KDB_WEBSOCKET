
//trade:([]event:`$();time:`float$();sym:`$();prchg:`float$();perchg:`float$();wavgp:`float$();prevcl:`float$();currcl:`float$();clqty:`float$();bid:`float$();bidqty:`float$();ask:`float$();askqty:`float$();op:`float$();low:`float$();bvol:`float$();qvol:`float$();opntime:`float$();closetime:`float$();ftid:`float$();ltid:`float$();num:`float$());
\p 5001 ;
px: ([] sym:`$();time:`timestamp$();bid:`float$();bidqty:`float$();ask:`float$();askqty:`float$());
pxusd: ([] sym:`$();time:`timestamp$();quote:`$();base:`$();usd:`$();bid:`float$();ask:`float$();bidqty:`float$();askqty:`float$());


arb:([] base:`$();pbid:`float$();pask:`float$();maxbid:`float$();minbid:`float$();maxask:`float$();minask:`float$();maxbidsym:`$();minbidsym:`$();maxasksym:`$();minasksym:`$());

mk:("BNB";"BTC";"ETH";"SDT");

`sym xkey `px;
`sym xkey `pxusd;
`base xkey `arb;

`px upsert enlist `sym`bid`ask!(`USDTUSDT; 1.0 ;1.0);

send:{[msg;h]neg[h].j.j msg};

.emit: {
    send[.j.j () xkey select sym,time,bid,bidqty,ask,askqty from px] each (key .z.W);
    send[.j.j () xkey select sym,time,bid,bidqty,ask,askqty from pxusd] each (key .z.W);

};

.z.ws:{ .upd .j.k x  };

.arb:{
`arb upsert
`base xkey select base,pbid:(maxbid-minbid)%minbid,pask:(maxask-minask)%maxask,maxbid,minbid,maxask,minask,maxbidsym,minbidsym,maxasksym,minasksym  from(
 ((`base xkey flip `maxbid`maxbidsym`base!(value flip select bid,sym,base from pxusd where bid = (max;bid) fby base)) lj
  ( `base xkey flip `minbid`minbidsym`base!(value flip select bid,sym,base from pxusd where bid = (min;bid) fby base)) lj
  ( `base xkey flip `maxask`maxasksym`base!(value flip select ask,sym,base from pxusd where ask = (max;ask) fby base)) lj
  ( `base xkey flip `minask`minasksym`base!(value flip select ask,sym,base from pxusd where ask = (min;ask) fby base)))
  )
};
.qccy: {[s] j:((count s)-3)_ s; b:mk like j; d:mk[where b]; v: raze d;  ssr[v;"SDT";"USDT"]};

.bccy:{[s] ssr[s;.qccy s;""]};

.usd:{[s] `$"" sv (.qccy s; "USDT") };

.ausdt: { [s]
  atb:select sym,time,bid,bidqty,ask,askqty from px;
  () xkey `atb;
  atb[`ask][atb[`sym]?.usd s]
};

.busdt: { [s]
  btb:select sym,time,bid,bidqty,ask,askqty from px;
  () xkey `btb;
  btb[`bid][btb[`sym]?.usd s]
};

.upd: { [y]
`px upsert flip `sym`time`bid`bidqty`ask`askqty!(`$y`s;"P"$string("i"$y[`E]%1000);"F"$y`b; "F"$y`B;"F"$y`a;"F"$y`A);

  send[.j.j (() xkey select sym,time,bid,bidqty,ask,askqty from px)] each (key .z.W);
  `pxusd upsert flip `sym`quote`base`usd`bid`ask`bidqty`askqty ! (`$(y`s) ;`$.qccy each  (y`s) ;`$.bccy each  (y`s);.usd each (y`s);(.busdt each y`s) * ("F"$y`b) ;(.ausdt each y`s) * ("F"$y`a);"F"$y`A;"F"$y`B);


};




.z.wo:{
  send[.j.j (() xkey select sym,bid,bidqty,ask,askqty from px)] each (key .z.W);
  send[.j.j (() xkey select base,pask,minasksym,maxasksym from arb)] each (key .z.W);

};


.temit:{
  send[.j.j (() xkey select sym,quote,bid,bidqty,ask,askqty from pxusd)] each (key .z.W);
  send[.j.j (() xkey select base,pbid,pask,minasksym,maxbidsym from arb)] each (key .z.W);

 };


r:(`$":ws://localhost:8080")"GET / HTTP/1.1\r\nHost: localhost:8080\r\n\r\n";
