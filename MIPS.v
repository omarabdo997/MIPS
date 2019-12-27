
module clk_generator(clk);
output reg clk=0;
always
begin
#5 clk<=~clk;
end
endmodule
module Mux_regdst(data,data1,data2,sel);
input wire sel;
input wire [4:0] data1,data2;
output reg [4:0] data;
always @(data1,data2,sel)
begin
if(sel==0)
begin
data<=data1;
end
else if(sel==1)
begin
data<=data2;
end
else
begin
data<=5'bx;
end
end
endmodule

module Mux_jal(write_register,b_write_register,Jal);
input wire Jal;
input wire [4:0] b_write_register;
wire [4:0] registerRa;
output reg [4:0] write_register;
assign registerRa=5'b11111;
always @(b_write_register,registerRa,Jal)
begin
if(Jal==0)
begin
write_register<=b_write_register;
end
else if(Jal==1)
begin
write_register<=registerRa;
end
else
begin
write_register<=5'bx;
end
end
endmodule




module Mux_alusrc(data,data1,data2,sel);
input wire sel;
input wire [31:0] data1,data2;
output reg [31:0] data;
always @(data1,data2,sel)
begin
if(sel==0)
begin
data<=data1;
end
else if(sel==1)
begin
data<=data2;
end
else
begin
data<=32'bx;
end
end
endmodule

module Mux_memtoreg(data,data1,data2,sel);
input wire sel;
input wire [31:0] data1,data2;
output reg [31:0] data;
always @(data1,data2,sel)
begin
if(sel==0)
begin
data<=data2;
end
else if(sel==1)
begin
data<=data1;
end
else
begin
data<=32'bx;
end
end
endmodule
module Mux_jaddress(data,data1,data2,sel);
input wire sel;
input wire [31:0] data1,data2;
output reg [31:0] data;
always @(data1,data2,sel)
begin
if(sel==0)
begin
data<=data2;
end
else if(sel==1)
begin
data<=data1;
end
else
begin
data<=32'bx;
end
end
endmodule

module extender2(jaddress,extendedinst);
input wire [29:0]extendedinst;
output wire [31:0] jaddress;
assign jaddress={2'b00,extendedinst};

endmodule
module Mux_pcsrc(data,data1,data2,sel);
input wire sel;
input wire [31:0] data1,data2;
output reg [31:0] data;
always @(data1,data2,sel)
begin
if(sel==0)
begin
data<=data1;
end
else if(sel==1)
begin
data<=data2;
end
else
begin
data<=32'bx;
end
end
endmodule

module shift_left(shifted,shift);
output wire [31:0] shifted;
input wire [29:0] shift;
assign shifted={shift,2'b00};
endmodule
module shift_left_extender(shifted,shift);
output wire [27:0] shifted;
input wire [25:0] shift;
assign shifted={shift,2'b00};
endmodule



module PC(instruction,last_instruction,ninstruction,clk);
output reg [31:0] instruction=0;
output reg [31:0] last_instruction=0;
input wire [31:0] ninstruction;
input clk;
always @(posedge clk )
begin
instruction<=ninstruction;
last_instruction<=instruction;
end
endmodule

module PC_add(ninstruction,instruction);
output wire [31:0] ninstruction;
input wire [31:0] instruction;
assign ninstruction=(instruction+4);

endmodule

module Instruction_memory(instruction_data,instruction,address,instruction_input,writememclk);
reg [31:0] instructionMemory [0:1023];
input writememclk;
input wire [9:0] instruction;
input wire [9:0] address;
input wire [31:0] instruction_input;
output reg [31:0] instruction_data=0;
always @(instruction or instructionMemory[instruction])
begin
instruction_data<=instructionMemory[instruction];

end
initial
begin
$readmemb("D://_tests_and_outputs/_test_5.txt",instructionMemory);
end
always @(posedge writememclk)
begin
instructionMemory[address]<=instruction_input;
end
endmodule

module Register_file(read_data1,read_data2,read_reg1,read_reg2,write_reg,write_data,reg_write,clk);
reg [31:0] register[0:31];
output wire [31:0] read_data1;
output wire [31:0] read_data2;
input wire [4:0] read_reg1;
input wire [4:0] read_reg2;
input wire [4:0] write_reg;
input wire[31:0] write_data;
assign read_data1=register[read_reg1];
assign read_data2=register[read_reg2];
input reg_write, clk;

always @(posedge clk)
begin

if(reg_write==1'b1 && write_reg!=0)
begin
register[write_reg]<=write_data;
end

end
always @(posedge clk)
$writememh("D://_tests_and_outputs/registermemory.txt",register);
initial
begin
register[0]=0;
register[29]=4092;
end
endmodule

module ALU(result,zero_flag,read_data1,read_data2,shemt,ALU_op);
input wire [31:0] read_data1,read_data2;
input wire [3:0] ALU_op;

output reg [31:0] result;
output wire zero_flag;
input wire [4:0] shemt;
assign zero_flag= read_data1==read_data2?1'b1:1'b0;
always @(read_data1 or read_data2 or ALU_op or shemt)
begin
if(ALU_op == 4'b0000)
begin
result<=read_data1 & read_data2;
end
else if(ALU_op == 4'b0001)
begin
result<=read_data1 | read_data2;
end
else if(ALU_op == 4'b0010)
begin
result<=read_data1 + (read_data2);
end
else if(ALU_op == 4'b0110)
begin
result<=read_data1 - read_data2;
end
else if(ALU_op == 4'b0111)
begin
result<=read_data1<read_data2?1:0;
end
else if(ALU_op == 4'b1110)
begin
result<=read_data2<<shemt;
end
else
begin
result<=32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
end
end
endmodule



module Sign_extend(extended_instruction,instruction);
input wire [15:0] instruction;
output wire [31:0] extended_instruction;
assign extended_instruction=instruction[15]==1?{16'b1111111111111111,instruction}:{16'b0000000000000000,instruction};

endmodule



module Data_memory(read_data,address,write_data,mem_write,mem_read,clk);
reg [31:0] mem[0:1023];
output reg [31:0] read_data;
input wire mem_write,mem_read,clk;
input wire [31:0] write_data;
input wire [9:0] address;
always @(address,write_data,mem_write,mem_read,mem[address])
begin
if(mem_read==1'b1)
begin
read_data<=mem[address];
end
else
begin
read_data<=32'bx;
end

end 
always @(posedge clk)
begin
if(mem_write==1)
begin
mem[address]<=write_data;
end
$writememh("D://_tests_and_outputs/datamemory.txt",mem);
end


endmodule

module Control(Jr,Jal,Jump,RegDst,Branch,MemRead,MemtoReg,ALUOp,MemWrite,ALUSrc,RegWrite,instruction,Function);
output reg RegDst,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,Jump,Jal,Jr;
output reg[1:0] ALUOp;
input [5:0] instruction,Function;
always @(instruction or Function)
begin
if(instruction==0 && Function==6'b001000)
begin
RegDst<=1'bx;
ALUSrc<=1'bx;
MemtoReg<=1'bx;
RegWrite<=0;
MemRead<=0;
MemWrite<=0;
Branch<=0;
ALUOp<=2'bxx;
Jump<=0;
Jal<=0;
Jr<=1'b1;
end
else if(instruction==0)
begin
RegDst<=1;
ALUSrc<=0;
MemtoReg<=0;
RegWrite<=1;
MemRead<=0;
MemWrite<=0;
Branch<=0;
ALUOp<=2'b10;
Jump<=0;
Jal<=0;
Jr<=0;
end
else if(instruction==6'b101011)
begin
RegDst<=1'bx;
ALUSrc<=1;
MemtoReg<=1'bx;
RegWrite<=0;
MemRead<=0;
MemWrite<=1;
Branch<=0;
ALUOp<=2'b00;
Jump<=0;
Jal<=0;
Jr<=0;
end
else if(instruction==6'b100011)
begin
RegDst<=0;
ALUSrc<=1;
MemtoReg<=1;
RegWrite<=1;
MemRead<=1;
MemWrite<=0;
Branch<=0;
ALUOp<=2'b00;
Jump<=0;
Jal<=0;
Jr<=0;
end
else if(instruction==6'b001000)
begin
RegDst<=0;
ALUSrc<=1;
MemtoReg<=0;
RegWrite<=1;
MemRead<=0;
MemWrite<=0;
Branch<=0;
ALUOp<=2'b00;
Jump<=0;
Jal<=0;
Jr<=0;
end
else if(instruction==6'b001101)
begin
RegDst<=0;
ALUSrc<=1;
MemtoReg<=0;
RegWrite<=1;
MemRead<=0;
MemWrite<=0;
Branch<=0;
ALUOp<=2'b11;
Jump<=0;
Jal<=0;
Jr<=0;
end
else if(instruction==6'b000100)
begin
RegDst<=1'bx;
ALUSrc<=0;
MemtoReg<=1'bx;
RegWrite<=0;
MemRead<=0;
MemWrite<=0;
Branch<=1;
ALUOp<=2'b01;
Jump<=0;
Jal<=0;
Jr<=0;
end
else if(instruction==6'b000010)
begin
RegDst<=1'bx;
ALUSrc<=1'bx;
MemtoReg<=1'bx;
RegWrite<=0;
MemRead<=0;
MemWrite<=0;
Branch<=1'bx;
ALUOp<=2'bxx;
Jump<=1'b1;
Jal<=0;
Jr<=0;
end
else if(instruction==6'b000011)  //jal
begin
RegDst<=1'bx;
ALUSrc<=1'bx;
MemtoReg<=1'bx;
RegWrite<=1;
MemRead<=0;
MemWrite<=0;
Branch<=1'bx;
ALUOp<=2'bxx;
Jump<=1'b1;
Jal<=1'b1;
Jr<=0;
end
else
begin
RegDst<=1'bx;
ALUSrc<=1'bx;
MemtoReg<=1'bx;
RegWrite<=1'bx;
MemRead<=1'bx;
MemWrite<=1'bx;
Branch<=1'bx;
ALUOp<=2'bxx;
Jump<=1'bx;
Jal<=1'bx;
Jr<=1'bx;
end
end

endmodule



module ALU_Control(ALU_op,ALUOp,instruction);
input wire [1:0] ALUOp;
input wire [5:0] instruction;
output reg [3:0] ALU_op;
always @(ALUOp or instruction)
begin
if(ALUOp==2'b00)
begin
ALU_op<=4'b0010;
end
else if(ALUOp==2'b01)
begin
ALU_op<=4'b0110;
end
else if(ALUOp==2'b11)
begin
ALU_op<=4'b0001;
end
else if(ALUOp==2'b10)
begin
case(instruction)
6'b100000:ALU_op<=4'b0010;
6'b100100:ALU_op<=4'b0000;//
6'b100101:ALU_op<=4'b0001;
6'b101010:ALU_op<=4'b0111;
6'b000000:ALU_op<=4'b1110;
default:ALU_op<=4'bxxxx;
endcase
end
else
begin
ALU_op<=4'bxxxx;
end
end

endmodule

module Branch_add(binstruction,ninstruction,extended);
output wire[31:0] binstruction;
input wire[31:0] ninstruction,extended;
assign binstruction=extended+ninstruction; 



endmodule


module mips_synthesizable(instruction_data,read_data,last_instruction,instruction,address,instruction_input,clk,writememclk);

input wire writememclk,clk;
input wire [31:0] instruction_input;
input wire [9:0] address;
output wire [31:0] instruction_data;
wire [31:0] write_data,b_write_data;
wire [31:0] extended,data2,result,binstruction,incinstruction,jaddress,b_ninstruction,extended_shifted;
wire [4:0] write_register ,b_write_register;
wire RegWrite,Jump,Jal;
wire RegDst,PCSrc;
wire Branch;
wire ALUSrc;
wire MemWrite;
wire MemRead;
wire MemtoReg;
wire [1:0] ALUOp;
wire zero_flag;
wire [3:0] ALU_op;
wire [27:0] extendedinst;
wire [31:0] ninstruction,read_data1,read_data2,n_instruction;
output wire [31:0] instruction,last_instruction;
output wire[31:0] read_data;
assign jaddress={incinstruction[31:28],extendedinst};
shift_left_extender s2(extendedinst,instruction_data[25:0]);
PC pc1(instruction,last_instruction,ninstruction,clk);
Instruction_memory IM(instruction_data,instruction[11:2],address,instruction_input,writememclk);
PC_add add1(incinstruction,instruction);
Mux_regdst regdst1(b_write_register,instruction_data[20:16],instruction_data[15:11],RegDst);
Mux_jal jal1(write_register,b_write_register,Jal);
Register_file f1(read_data1,read_data2,instruction_data[25:21],instruction_data[20:16],write_register,write_data,RegWrite,clk);
Sign_extend extend1(extended,instruction_data[15:0]);
Mux_alusrc alusrc1(data2,read_data2,extended,ALUSrc);
Mux_pcsrc pcsrc1(n_instruction,incinstruction,binstruction,PCSrc);
and (PCSrc,Branch,zero_flag);
ALU alu1(result,zero_flag,read_data1,data2,instruction_data[10:6],ALU_op);
Data_memory DM1(read_data,result[11:2],read_data2,MemWrite,MemRead,clk);
Mux_memtoreg memtoreg1(b_write_data,read_data,result,MemtoReg);
Control c1(Jr,Jal,Jump,RegDst,Branch,MemRead,MemtoReg,ALUOp,MemWrite,ALUSrc,RegWrite,instruction_data[31:26],instruction_data[5:0]);
ALU_Control alucontrol1(ALU_op,ALUOp,instruction_data[5:0]);
Branch_add b_add1(binstruction,incinstruction,extended_shifted);
Mux_jaddress jad1(b_ninstruction,jaddress,n_instruction,Jump);
Mux_alusrc jal2(write_data,b_write_data,incinstruction,Jal);
Mux_alusrc jr(ninstruction,b_ninstruction,read_data1,Jr);
shift_left sl(extended_shifted,extended[29:0]);




endmodule


module tb_mips2019;
wire clk,writememclk;
integer f;
wire [31:0] read_data,last_instruction,instruction,instruction_input,instruction_data;
wire [9:0] address;
clk_generator clock(clk);
mips_synthesizable mips(instruction_data,read_data,last_instruction,instruction,address,instruction_input,clk,writememclk);
always @(instruction)
begin
if(instruction_data===32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
$finish;
end

always @(posedge clk )
begin
f=$fopen("D://_tests_and_outputs/PC.txt","w");
$fwrite(f,"%h",last_instruction);
$fclose(f); 

end
endmodule





