%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdbool.h>




extern FILE *yyin;
extern int yylex();
void yyerror (char *msg);

int D = 0;
int now_exp = -1;
int max_exp = 0;
int now_ifs = -1;
int max_ifs = 0;
int max_sens = 5;
int max_dev = 5;
int l=0;

struct devices {
	char name[50];
	int condition;
};

struct sensors{
	char name[50];
	int condition;
};

struct expectation{
	char *name;
	char *expaction;
	char exptime;
};

struct ifs {
	char *name_sensor;
	char *action_sensor;
	char *name_device;
	char *action_device;
};

struct sensors activity[] = {"SMOKE",0,"WATER",0,"MOOVEMENT",0,"DOOR",0,"WINDOW",0};
struct devices work[] = {"LAMP",0,"VACUUM",0,"ALARM",0,"KETTLE",0,"TV"};
struct expectation *expect = NULL;
struct ifs *conditions = NULL;


char FILEREAD() {
	FILE *timefile;
	timefile = fopen("Time.txt","r");
	char TIME;
	do{
		TIME = getc(timefile);
		break;
	}while (TIME != EOF);
	fclose(timefile);
	
	return TIME;
}


void FILESENSORS(){
	FILE * cond_sens;
	int i=0;
	char *saveptr;
	char name[50];
	char nums[50];
	cond_sens = fopen("Sensors_condition.txt","r");
	char Sensors_cond[max_sens][50];
	while (!feof(cond_sens)) {
		fgets(Sensors_cond[i],50,cond_sens);
		i++;
	}
	
	
	for(int s=0; s<max_sens;s++) {
		sprintf(name,"%s",strtok_r(Sensors_cond[s],":",&saveptr));
		sprintf(nums,"%s",strtok_r(NULL,":",&saveptr));
		for(int b=0;b<max_sens;b++){
			if(strcmp(activity[b].name,name)==0){
				activity[b].condition = atoi(nums);
			}
		}
	}
}

void monitoring_exp(){
	char TIME = FILEREAD();
	for (int i =0; i<=now_exp;i++){
			for(int b=0;b<max_dev;b++){
				if(strcmp(work[b].name, expect[i].name) == 0){
					if(TIME==expect[i].exptime){
						if (strcmp(expect[i].expaction,"on")==0){
							if(work[b].condition == 0 ){
								printf("%s %s",expect[i].name," is on\n");
								work[b].condition=1;
								l=0;
							}
						}
						if (strcmp(expect[i].expaction,"off")==0){
							if(work[b].condition == 1){
								printf("%s %s",expect[i].name," is off \n");
								work[b].condition=0;
								l=0;
							}
						}
					}
					else if (TIME != expect[i].exptime && l==0){
						printf("%s %s",expect[i].name," is off \n");
						work[b].condition=0;
						l++;
					}
				}	
			
			}

		
		}
	}

		     
void monitoring_ifs() {
	FILESENSORS();
	for (int i = 0; i <= now_ifs; i++){
		for(int b = 0; b<max_sens;b++){
			if(strcmp(conditions[i].name_sensor,activity[b].name)==0){
				if(strcmp(conditions[i].action_sensor,"on")==0 && activity[b].condition==1){
					for(int d = 0;d<max_dev;d++){
						if(strcmp(conditions[i].name_device,work[d].name)==0){
							if (strcmp(conditions[i].action_device,"on")==0){
								if(work[d].condition == 0 ){
									printf("%s %s",work[d].name," is on\n");
									work[d].condition=1;
								}
							}
							if (strcmp(conditions[i].action_device,"off")==0){
								if(work[d].condition == 1){
									printf("%s %s",work[d].name," is off \n");
									work[d].condition=0;
								}
							}
							u=0;	
						}
					}
				}
				else if(strcmp(conditions[i].action_sensor,"off")==0 && activity[b].condition==0){
					for(int d = 0;d<max_dev;d++){
						if(strcmp(conditions[i].name_device,work[d].name)==0){
							if (strcmp(conditions[i].action_device,"on")==0){
								if(work[d].condition == 0 ){
									printf("%s %s",work[d].name," is on\n");
									work[d].condition=1;
								}
							}
							if (strcmp(conditions[i].action_device,"off")==0){
								if(work[d].condition == 1){
									printf("%s %s",work[d].name," is off \n");
									work[d].condition=0;
								}
							}
							u=0;	
						}
					}
				}
				else if(strcmp(conditions[i].action_sensor,"off")==0 && activity[b].condition==1){
					for(int d = 0;d<max_dev;d++){
						if(strcmp(conditions[i].name_device,work[d].name)==0){		
							work[d].condition=0;
						}
					}
				}
				else if(strcmp(conditions[i].action_sensor,"on")==0 && activity[b].condition==0){
					for(int d = 0;d<max_dev;d++){
						if(strcmp(conditions[i].name_device,work[d].name)==0){		
							work[d].condition=0;
						}
					}
				}
			
			}
		
		}
		
		
	}

}	     
			
void monitoring (){
	while (true) {;
		monitoring_exp();
		monitoring_ifs();

		
		sleep(3);
	}
}
%}


%union {
	char *tur;
	char *dev;
	char *act;
	char *iff;
	char *brak;
	char tim;
}


%token <tur> turn
%token <dev> device
%token <act> action
%token <iff> iffs
%token <brak> bracket
%token <tim> time
%token end;
%type Scenario line


%%
Scenario : 
	 | Scenario line

	 ;




line 	 : turn device action					{
								int c=0;
								for(int i=0;i<max_dev;i++){
									if(strcmp($2,work[i].name)==0){
										if (strcmp($3,"on")==0&&work[i].condition==0){
											printf("%s %s",$2," is on \n");
											work[i].condition=1;
										}
										else if (strcmp($3,"on")==0&&work[i].condition==1){
											printf("%s %s",$2," is already on \n");
										}
										else if (strcmp($3,"off")==0&&work[i].condition==1){
											printf("%s %s",$2," is off \n");
											work[i].condition=0;
										}
										else if(strcmp($3,"off")==0&&work[i].condition==0){
											printf("%s %s",$2," is already off \n");
										}
										c++;
									}
								}
								if (c==0){
									printf("Device not found \n");
								}
								}
								
								

	|iffs device action bracket device action bracket	{
								D++;
								now_ifs++;

								if (now_ifs >= max_ifs) {
									if (max_ifs == 0)
										max_ifs++;
									max_ifs *= 2;
									conditions = (struct ifs*)realloc(conditions, sizeof(struct ifs) * max_ifs);
								}

								struct ifs *condition = (struct ifs*)malloc(sizeof(struct ifs));
								condition->name_sensor = $2;
								condition->action_sensor = $3;
								condition->name_device = $5;
								condition->action_device = $6;

								conditions[now_ifs] = *condition;
								}
								
								

	| turn device action time 				{
								D++;
								int c=0;
								char TIME =FILEREAD();
								now_exp++;
								if(now_exp >= max_exp){
									if(max_exp==0){
										max_exp++;
									}
									max_exp*=2;
									expect = (struct expectation *)realloc(expect,sizeof(struct expectation)*max_exp);
								}
								struct expectation * exp = (struct expectation *) malloc(sizeof( struct expectation));
								exp->name = $2;
								exp->expaction =$3;
								exp->exptime = $4;
								expect[now_exp]=*exp;
								}


	| end							{
								if(D!=0){
									monitoring();
								}
								}	
												
	;
%%




void yyerror(char *msg) {
	fprintf(stderr, "%s\n", msg);
}

int main() {
	char input [100];
	printf("Enter file name \n");
	scanf("%s",input);
	FILE *COD = fopen(input,"r");
	yyin = COD;
	yyparse();
	return 1;
}
