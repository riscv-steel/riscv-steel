int main()
{
    char* UART_ADDRESS = (char*)0x00010000;
    char hello[20] = "Hello World, Steel!\0";
    int i = 0;
    for(i = 0; i < 20; i++)
    {
        while((*UART_ADDRESS) != 1);
        (*UART_ADDRESS) = hello[i];
    }
    for(;;);
}
