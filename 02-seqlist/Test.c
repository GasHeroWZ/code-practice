#include "SeqList.h"

void TestSeqList1()
{
	SL sl;
	SeqListInit(&sl);
	SeqListPushBack(&sl, 1);
	SeqListPushBack(&sl, 2);
	SeqListPushBack(&sl, 3);
	SeqListPushBack(&sl, 4);
	SeqListPushBack(&sl, 5);
	SeqListPrint(&sl);

	SeqListPopBack(&sl);
	SeqListPopBack(&sl);
	SeqListPopBack(&sl);
	SeqListPopBack(&sl);
	SeqListPopBack(&sl);
	//SeqListPopBack(&sl);
	//SeqListPopBack(&sl);
	SeqListPrint(&sl);

	SeqListPushBack(&sl, 10);
	SeqListPushBack(&sl, 20);
	SeqListPrint(&sl);

	SeqListDestory(&sl);
}

void TestSeqList2()
{
	SL sl;
	SeqListInit(&sl);
	SeqListPushBack(&sl, 1);
	SeqListPushBack(&sl, 2);
	SeqListPushBack(&sl, 3);
	SeqListPushBack(&sl, 4);
	SeqListPushBack(&sl, 5);
	SeqListPrint(&sl);

	SeqListPushFront(&sl, 10);
	SeqListPushFront(&sl, 20);
	SeqListPushFront(&sl, 30);
	SeqListPushFront(&sl, 40);
	SeqListPrint(&sl);

	SeqListPopFront(&sl);
	SeqListPopFront(&sl);
	SeqListPrint(&sl);

	SeqListDestory(&sl);
}

// 写一个类似通讯录的菜单
void menu()
{
	printf("************************************\n");
	printf("请选择你的操作:>\n");
	printf("1、头插  2、头删\n");
	printf("3、尾插  4、尾删\n");
	// ...
	printf("************************************\n");
}

void TestSeqList3();   // 前向声明，避免隐式声明警告

int main()
{
	TestSeqList1();
	TestSeqList2();

	// 实现完下面三个接口后，把这一行取消注释：
	//TestSeqList3();

	return 0;
}
// ================== 练习自测：实现完上面三个接口后启用 ==================
void TestSeqList3()
{
	SL sl;
	SeqListInit(&sl);
	SeqListPushBack(&sl, 1);
	SeqListPushBack(&sl, 2);
	SeqListPushBack(&sl, 3);
	printf("初始:      "); SeqListPrint(&sl);          // 期望 1 2 3

	printf("Find(2)  = %d  (期望 1)\n",  SeqListFind(&sl, 2));
	printf("Find(99) = %d  (期望 -1)\n", SeqListFind(&sl, 99));

	SeqListInsert(&sl, 1, 100);
	printf("插入100:   "); SeqListPrint(&sl);          // 期望 1 100 2 3

	SeqListInsert(&sl, 0, 7);
	printf("头插7:     "); SeqListPrint(&sl);          // 期望 7 1 100 2 3

	SeqListErase(&sl, 0);
	printf("删第一个:  "); SeqListPrint(&sl);          // 期望 1 100 2 3

	SeqListErase(&sl, 3);
	printf("删最后一个:"); SeqListPrint(&sl);          // 期望 1 100 2

	SeqListDestory(&sl);
}