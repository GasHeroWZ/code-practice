#include <stdio.h>

/* 题目: 判断大小端 + 按字节打印一个 int
 * 输入: 一个整数
 * 输出: 第一行 little 或 big, 第二行 4 个字节(十六进制, 空格分隔, 内存从低地址到高地址)
 * 要求: 实现 IsLittleEndian (用 union 或 char* 取首字节)
 *       实现 PrintBytes, 把 int 的地址转成 unsigned char* 后逐字节打印 %02X
 * 提示: 这是理解"变量在内存里怎么摆"的关键题, 配合第 19 讲一起看
 */
int IsLittleEndian(void)
{
    /* TODO: 返回 1 表示小端, 0 表示大端 */
    return 0;
}

void PrintBytes(int x)
{
    /* TODO: 打印 4 个字节 */
    (void)x;
}

int main(void)
{
    int x = 0;
    if (scanf("%d", &x) != 1) return 0;
    printf("%s\n", IsLittleEndian() ? "little" : "big");
    PrintBytes(x);
    return 0;
}