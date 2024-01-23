// Include common routines
#include "run.h"
#include "verilated.h"

int main(int argc, char **argv)
{

  if (false && argc && argv)
  {
  }

  // Construct context to hold simulation time, etc
  VerilatedContext *contextp = new VerilatedContext;
  contextp->debug(0);
  contextp->randReset(2);
  contextp->commandArgs(argc, argv);

  // Construct the Verilated model, including the secret module
  run *top = new run{contextp};

  top->clock = 0;

  // Simulate until $finish
  while (!contextp->gotFinish())
  {
    contextp->timeInc(1);
    top->clock = ~top->clock & 0x1;
    top->eval();
  }

  // Final model cleanup
  top->final();

  // Destroy model
  delete top;
  delete contextp;

  // Return good completion status
  // Don't use exit() or destructor won't get called
  return 0;
}