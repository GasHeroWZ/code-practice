#include <stdio.h>

/* 题目: 手写 memcpy 并用它复制 int 数组
 * 输入: n, 然后 n 个整数
 * 输出: 复制后的数组, 每个数后跟一个空格
 * 要求: 实现 MyMemcpy, 参数是 void* 和字节数, 内部按 unsigned char* 逐字节复制
 * 提示: void* 不能直接解引用, 必须先转成 unsigned char*
 * 注意: 这是理解"内存就是字节"的关键一题
 */
void* MyMemcpy(void* dst, const void* src, unsigned int n)
{
    /* TODO */
    (void)dst; (void)src; (void)n;
    return dst;
}

int main(void)
{
    int n = 0, src[100], dst[100];
    if (scanf("%d", &n) != 1 || n <= 0 || n > 100) return 0;
    for (int i = 0; i < n; ++i) scanf("%d", &src[i]);
    MyMemcpy(dst, src, sizeof(int) * (unsigned)n);
    for (int i = 0; i < n; ++i) printf("%d ", dst[i]);
    printf("\n");
    return 0;
}