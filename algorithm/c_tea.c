/* 128-bit key in k[0] .. k[3].   64-bit data in v[0] .. v[1]. */
/* http://www.cl.cam.ac.uk/ftp/papers/djw-rmn/djw-rmn-tea.html */
main (int artgc, char **argv, char **env) {
   unsigned long v[2], k[4];

   v[0] = 0x12345678; v[1] = 0x9abcdef0;
	k[0] = 0x61626364; k[1] = 0x62636465;
	k[2] = 0x63646566; k[3] = 0x64656667;

   printf ("c_tea:\n");
   printf ("    key = 0x%x %x %x %x\n\n", k[0], k[1], k[2], k[3]);
   printf ("      v = 0x%x %x\n", v[0], v[1]);

   tea_code (v, k);
   printf ("  coded = 0x%x %x\n", v[0], v[1]);

   tea_decode (v, k);
   printf ("decoded = 0x%x %x\n", v[0], v[1]);
}

encrypt () {
}

decrypt () {
}

tea_code(long* v, long* k)  {   /* long is 4 bytes. */
   unsigned long v0=v[0], v1=v[1], k0=k[0], k1=k[1], k2=k[2], k3=k[3],
		sum=0, delta=0x9e3779b9, n=32 ;
   while (n-- > 0) {
      sum += delta ;
      v0 += (v1<<4)+k0 ^ v1+sum ^ (v1>>5)+k1 ;
      v1 += (v0<<4)+k2 ^ v0+sum ^ (v0>>5)+k3 ;
   }
   v[0]=v0 ; v[1]=v1 ;
}
tea_decode(long* v, long* k)  {
   unsigned long v0=v[0], v1=v[1], k0=k[0], k1=k[1], k2=k[2], k3=k[3],
   n=32, sum, delta=0x9e3779b9 ;
   sum=delta<<5 ;
   while (n-- > 0) {
      v1 -= (v0<<4)+k2 ^ v0+sum ^ (v0>>5)+k3 ;
      v0 -= (v1<<4)+k0 ^ v1+sum ^ (v1>>5)+k1 ;
      sum -= delta ;
   }
   v[0]=v0 ; v[1]=v1 ;
}
