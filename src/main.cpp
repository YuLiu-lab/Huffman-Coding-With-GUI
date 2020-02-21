#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define queueSize_Max 256 //������󳤶�
#define code_Max 256 //������󳤶�

char src[100];//�ļ�����·�� 

typedef struct hfmTreeNode {
	int symbol;
	struct hfmTreeNode *left;
	struct hfmTreeNode *right;
} hfmTreeNode, *phTreeNode;

typedef struct hHfmTreeNode {
	hfmTreeNode* rootNode;
} hHfmTreeNode;

typedef struct queueNode {
	phTreeNode ptr;
	int count;
	struct queueNode *next;
} queueNode, *ptrQueue;

typedef struct hQueueNode {
	int size;
	ptrQueue first;
} hQueueNode;

typedef struct tableNode {
	char symbol;
	char* code;
	struct tableNode *next;
} tableNode;

typedef struct hdTableNode {
	tableNode *first;
	tableNode *last;
} hdTableNode;

void initQueue(hQueueNode** hQueue)
{
	*hQueue = (hQueueNode*)malloc(sizeof(hQueueNode));
	(*hQueue)->size = 0;
	(*hQueue)->first = NULL;
}

void addQueueNode(hQueueNode **hQueue, hfmTreeNode *hNode, int count)
{
	queueNode *qNode = NULL;

	if ((*hQueue)->size == queueSize_Max)
	{
		printf("\nERR: The queue is full!!!");
	}
	else
	{
		if (0 == (*hQueue)->size)
		{
			qNode = (queueNode*)malloc(sizeof(queueNode));
			(*hQueue)->first = qNode;
			qNode->count = count;
			qNode->ptr = hNode;
			qNode->next = NULL;
			(*hQueue)->size++;
		}
		else if (count<(*hQueue)->first->count)
		{
			qNode = (queueNode*)malloc(sizeof(queueNode));
			qNode->next = (*hQueue)->first;
			(*hQueue)->first = qNode;
			qNode->count = count;
			qNode->ptr = hNode;
			(*hQueue)->size++;
		}
		else
		{
			queueNode* p = (*hQueue)->first;
			qNode = (queueNode*)malloc(sizeof(queueNode));
			qNode->count = count;
			qNode->ptr = hNode;
			(*hQueue)->size++;

			while (p->next != NULL && count >= p->next->count)
				p = p->next;
			qNode->next = p->next;
			p->next = qNode;
		}
	}
}

hfmTreeNode* getHfmTreeNode(hQueueNode* hQueue)
{
	hfmTreeNode* getNode;
	if (hQueue->size>0)
	{
		getNode = hQueue->first->ptr;
		hQueue->first = hQueue->first->next;
		hQueue->size--;
	}
	else
	{
		printf("\nERR: Can't get a node\n");
	}
	return getNode;
}


hHfmTreeNode* crtHfmTree(hQueueNode** hQueue)
{
	int count = 0;
	hfmTreeNode *left, *right;

	while ((*hQueue)->size>1)
	{
		count = (*hQueue)->first->count + (*hQueue)->first->next->count;
		left = getHfmTreeNode(*hQueue);
		right = getHfmTreeNode(*hQueue);

		hfmTreeNode *newNode = (hfmTreeNode*)malloc(sizeof(hfmTreeNode));

		newNode->left = left;
		newNode->right = right;

		addQueueNode(hQueue, newNode, count);
	}

	hHfmTreeNode* tree = (hHfmTreeNode*)malloc(sizeof(hHfmTreeNode));
	tree->rootNode = getHfmTreeNode(*hQueue);
	return tree;
}

hHfmTreeNode* creatTree(void)
{
	FILE *ifile;
	FILE *fp;//��������ַ�ͳ��
	int *countArray;
	char c;
	int i;

	countArray = (int*)malloc(sizeof(int) * 256);//����ռ����ڴ洢���ַ����ֵĴ���,����ʼ��Ϊ��
	for (i = 0; i<256; i++)
	{
		countArray[i] = 0;
	}

	ifile = fopen(src, "r");
	if (!ifile)  //����ļ��Ƿ�򿪳ɹ�
		printf("Can't open the file\n");
	else
	{
		while ((c = getc(ifile)) != EOF)
		{
			countArray[(unsigned int)c]++;
			printf("%c", c);
		}
		fclose(ifile);
	}
	hQueueNode *hQueue;
	initQueue(&hQueue);
	for (i = 0; i<256; i++)
	{
		if (countArray[i])
		{
			hfmTreeNode *hNode = (hfmTreeNode*)malloc(sizeof(hfmTreeNode));//����һ�����ڵ㣬����ʼ����������Ӧ����queueNode�е�ptr��

			hNode->symbol = (char)i;
			hNode->left = NULL;
			hNode->right = NULL;

			addQueueNode(&hQueue, hNode, countArray[i]);//���ýڵ��������е��ʵ�λ�ã���ͳ�ƵĽ������С�������У�
		}
	}
	free(countArray);//�ͷ�

	queueNode* q = hQueue->first;
	fp = fopen("char count.txt", "w");
	do
	{
		if (q->ptr->symbol == '\n')//�س��ո����⴦��
			fprintf(fp, "\\n %d\n", q->count);
		else
			fprintf(fp, "%c %d\n", q->ptr->symbol, q->count);//���ַ�ͳ��������ļ�char count.txt�б��棬��ʽ���ַ� ����\n
		q = q->next;
	} while (q->next != NULL);//��ֹ�����һ���س�
	fprintf(fp, "%c %d", q->ptr->symbol, q->count);
	hHfmTreeNode *tree = crtHfmTree(&hQueue);
	return tree;
}

void traverseTree(hdTableNode** table, hfmTreeNode* tree, char* code, int k)
{
	if (tree->left == NULL && tree->right == NULL)   //�ݹ������飬���ҵ�Ҷ�ӽڵ�
	{
		code[k] = '\0';   //����ַ����������
		tableNode *tNode = (tableNode*)malloc(sizeof(tableNode)); //����һ���ڵ㣬��������ӵ�table������
		tNode->code = (char*)malloc(sizeof(char) * 256 + 1);
		strcpy(tNode->code, code);
		tNode->symbol = tree->symbol;
		tNode->next = NULL;

		if ((*table)->first == NULL)   //����ǵ�һ���ڵ㣬ֱ����Ӽ��ɣ� ������ӵ�β������
		{
			(*table)->first = tNode;
			(*table)->last = tNode;
		}
		else
		{
			(*table)->last->next = tNode;
			(*table)->last = tNode;
		}
	}

	if (tree->left != NULL)    //����ߵݹ飬����¼����Ϊ0
	{
		code[k] = '0';
		traverseTree(table, tree->left, code, k + 1);
	}

	if (tree->right != NULL)   //���ұߵݹ飬����¼����Ϊ1
	{
		code[k] = '1';
		traverseTree(table, tree->right, code, k + 1);
	}
}

hdTableNode* crtTable(hHfmTreeNode* hfmTree)
{
	hdTableNode* hdTable = (hdTableNode*)malloc(sizeof(hdTableNode));
	hdTable->first = NULL;
	hdTable->last = NULL;

	char code[code_Max];
	int k = 0; //��¼���Ĳ㼶

	traverseTree(&hdTable, hfmTree->rootNode, code, k);
	return hdTable;
}

int main(int argc,char *argv[])
{
	if(argc < 2)
		return -1;
	else
	{
		FILE *test;//���ڲ����ļ��Ƿ����
		test = fopen(argv[1], "r");
		if (!test)
			return -2;
		printf("%d %s\n", argc,argv[1]);
		strcpy(src, argv[1]);
		FILE *fp;
		hHfmTreeNode* tree;
		hdTableNode* table;
		//�����ļ�������
		tree = creatTree();
		table = crtTable(tree);

		int i = 0, j = 0, flagn = 1;//flagn�����ж��Ƿ�����\n
		tableNode* t = table->first;
		char* s = t->code;
		//���������
		fp = fopen("coding result.txt", "w");
		while (t != NULL)
		{
			if (t->symbol == '\n')//�����س����⴦�����Ϊ\n�������ʽ����
				fprintf(fp, "\\n ");
			else
				fprintf(fp, "%c ", t->symbol);
			for (i = 0; i<257; i++)
			{
				if ((*s) != '\0')
				{
					fprintf(fp, "%c", *s);
					s++;
				}
			}
			if (t->next == NULL)
				break;
			fprintf(fp, "\n");
			t = t->next;
			if (t)
				s = t->code;
		}
	}
	
}
