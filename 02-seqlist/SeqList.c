#include "SeqList.h"

void SeqListPrint(SL* ps)
{
	for (int i = 0; i < ps->size; ++i)
	{
		printf("%d ", ps->a[i]);
	}
	printf("\n");
}

void SeqListInit(SL* ps)
{
	ps->a = NULL;
	ps->size = ps->capacity = 0;
}

void SeqListDestory(SL* ps)
{
	free(ps->a);
	ps->a = NULL;
	ps->capacity = ps->size = 0;
}

void SeqListCheckCapacity(SL* ps)
{
	// 如果没有空间或者空间不足，那么我们就扩容
	if (ps->size == ps->capacity)
	{
		int newcapacity = ps->capacity == 0 ? 4 : ps->capacity * 2;
		SLDataType* tmp = (SLDataType*)realloc(ps->a, newcapacity*sizeof(SLDataType));
		if (tmp == NULL)
		{
			printf("realloc fail\n");
			exit(-1);
		}

		ps->a = tmp;
		ps->capacity = newcapacity;
	}
}

void SeqListPushBack(SL* ps, SLDataType x)
{
	SeqListCheckCapacity(ps);

	ps->a[ps->size] = x;
	ps->size++;
}

void SeqListPopBack(SL* ps)
{
	// 温柔处理方式
	//if (ps->size > 0)
	//{
	//	//ps->a[ps->size - 1] = 0;
	//	ps->size--;
	//}

	// 暴力处理方式
	assert(ps->size > 0);
	ps->size--;
}

void SeqListPushFront(SL* ps, SLDataType x)
{
	SeqListCheckCapacity(ps);

	// 挪动数据
	int end = ps->size - 1;
	while (end >= 0)
	{
		ps->a[end + 1] = ps->a[end];
		--end;
	}
	ps->a[0] = x;
	ps->size++;
}

void SeqListPopFront(SL* ps)
{
	assert(ps->size > 0);

	// 挪动数据
	int begin = 1;
	while (begin < ps->size)
	{
		ps->a[begin - 1] = ps->a[begin];
		++ begin;
	}

	ps->size--;
}
// ================== 练习：请实现下面三个接口 ==================
// 头文件里已经声明了它们，但课程讲到 10/12 时还没写。
// 提示：
//   1. SeqListFind 返回下标，找不到返回 -1
//   2. SeqListInsert 要先断言 pos 合法，再 SeqListCheckCapacity，然后把 pos 及之后的数据整体后移一位
//   3. SeqListErase 要先断言 pos 合法，然后把 pos 之后的数据整体前移一位
//   4. 实现 Insert 之后，PushBack 等价于 Insert(size, x)，PushFront 等价于 Insert(0, x) —— 可以试试重构

int SeqListFind(SL* ps, SLDataType x)
{
	// TODO: 遍历 0..size-1，找到返回 i，找不到返回 -1
	(void)ps; (void)x;
	return -1;
}

void SeqListInsert(SL* ps, int pos, SLDataType x)
{
	// TODO: 断言 0 <= pos <= size；检查容量；搬数据；写入；size++
	(void)ps; (void)pos; (void)x;
}

void SeqListErase(SL* ps, int pos)
{
	// TODO: 断言 0 <= pos < size；搬数据；size--
	(void)ps; (void)pos;
}