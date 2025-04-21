#总体思想1深度buf的作为缓冲

注意可以读/可以写
与正在读/正在写的区别

#backward
目的：把ready打拍输出到上级，以优化ready的时序
需要一个深度为1的buf，tready_i作为指示buf为空的标志信号

写使能为tready_i & tvalid_i
读使能为tready_o & tvalid_o

什么时候可以写呢？（保证tready_i时序逻辑输出）
1.buf空
assign tready_i = buf_empty;

什么时候可以读呢？
1.buf非空时，
2.buf为空,此时正在写

assign tvalid_o = buf_empty ? tvalid_i : 1'b1;
assign tdata_o  = buf_empty ? tdata_i  : buf_data;

buf的empty怎么置高置低呢
1.buf复位后为空
2.buf为空，只写后置0，并寄存数据
3.buf为空，边写边读后维持空，数据直通
4.buf为非空，只读后置空
5.buf为非空，此时不会出现边写边读，因为tready_i为buf_empty此时不会出发写使能


#forward
目的：把valid和data打拍输出到下级，以优化两者的时序
需要一个深度为1的buf，tvalid_o作为指示buf为满的标志信号，故数据肯定要先写进buf，然后再出来
写使能为tready_i & tvalid_i
读使能为tready_o & tvalid_o

什么时候可以读呢？（需要保证tvalid_o/tdata_o时序逻辑输出）
1.buf满
由此 tvalid_o = buf_full;
     tdata_o  = buf_data;

什么时候可以写呢？
1.buf非满
2.buf满，但此时正在读
由此 tready_i =  buff_full ? tready_o : 1'b1;

buf的full怎么置高及置低呢？

1.buf非满，只写后置高
2.buf满，边写边读后维持置高
3.buf满，只读后置低
4.buf非满，不会出现边写边读，因为tvalid_o = buf_full;




	

