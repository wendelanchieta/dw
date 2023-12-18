=================================================
docker run -d --restart always --privileged=true -p 9306:3306 -p 9090:8080 -e TZ=America/Sao_Paulo -e MYSQL_ROOT_PASSWORD=R3d1m1n3 -v /var/docker_data/mysql-dw:/var/lib/mysql --name mysql-dw-teste mysql:latest
=================================================
docker exec ${CONTAINER_NAME} mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "drop schema test; create schema test;"
=================================================
docker exec -i 072d04c1d5e9 sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD"; && show databases;'
=================================================
"Env": [
		"MYSQL_ROOT_PASSWORD=example",
		"MYSQL_DATABASE=redmine",
		"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
		"GOSU_VERSION=1.14",
		"MYSQL_MAJOR=8.0",
		"MYSQL_VERSION=8.0.30-1.el8",
		"MYSQL_SHELL_VERSION=8.0.30-1.el8"
	]
=================================================
mysql -u root -p$MYSQL_ROOT_PASSWORD	
=================================================
docker exec -it 072d04c1d5e9 /bin/bash -c 'mysql -u root -p$MYSQL_ROOT_PASSWORD; show databases;'
=================================================
mysqldump -u root -p$MYSQL_ROOT_PASSWORD redmine > /var/backup/redmine-bkp-27112023.sql
=================================================
docker exec 072d04c1d5e9 -c 'mysqldump -u root -p$MYSQL_ROOT_PASSWORD redmine' > /tmp/redmine-bkp-27112023.sql
=================================================
docker exec -i some-mysql sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD"' < /var/backup/redmine-bkp-20102023.sql
=================================================
docker cp 072d04c1d5e9:/var/backup/redmine-bkp-20112023.sql .
=================================================
select id,name, homepage, parent_id,identifier from projects where parent_id = 7 or id =7;
=================================================
Select subject as assunto, count(1) as Quantidade_tarefas from issues where project_id in (select id from projects where parent_id in (4,7,21,30,31,34) or id =7) group by subject;
=================================================
Select 
	p.name,
	count(1) as Quantidade_tarefas 
from issues i
inner join projects as p on p.id = i.project_id
where i.project_id in (select id from projects where parent_id in (4,7,21,30,31,34) or id =7)
group by p.name;
=================================================
-- criação da base de dados
 
create database redmine_dw /*!40100 default character set utf8mb4 collate utf8mb4_0900_ai_ci */;
=================================================

-- Exclusão tabelas

drop table if exists redmine_dw.ft_ss_redmine;

drop table if exists redmine_dw.dim_projeto;

drop table if exists redmine_dw.dim_sprint;

drop table if exists redmine_dw.dim_usuario;

drop table if exists redmine_dw.dim_tarefa;


-----------------------------------------------------------------------------------------------------------------------------------

-- criação tabela  redmine_dw.dim_projeto

/*==============================================================*/
/* table: dim_projeto                                           */
/*==============================================================*/

create table redmine_dw.dim_projeto
(
   idw_projeto          int not null auto_increment,
   id_projeto           int not null,
   nome                 varchar(255) not null,
   descricao            text,
   parent_id            int,
   identificador        varchar(255) not null,
   primary key (idw_projeto)
);
-----------------------	

-- criação tabela  redmine_dw.dim_sprint

/*==============================================================*/
/* table: dim_sprint                                            */
/*==============================================================*/
create table redmine_dw.dim_sprint
(
   idw_sprint           int not null auto_increment,
   id_sprint            int not null,
   nome                 varchar(255) not null,
   descricao            text,
   id_usuario           int not null,
   id_projeto           int not null,
   data_inicial         date,
   data_final           date,
   data_criacao         datetime not null,
   data_atualizacao     datetime not null,
   primary key (idw_sprint)
);  

-----------------------

-- criação tabela  redmine_dw.dim_usuario

/*==============================================================*/
/* table: dim_usuario                                           */
/*==============================================================*/
create table redmine_dw.dim_usuario
(
   idw_usuario          int not null auto_increment,
   id_usuario           int not null,
   nome                 varchar(255) not null,
   login                varchar(255) not null,
   email                varchar(255) not null,
   tipo                 varchar(15) not null,
   status               varchar(15) not null,
   data_ultimo_login    datetime,
   data_criacao         datetime not null,
   data_atualizacao     datetime not null,
   primary key (idw_usuario)
);
-----------------------

-- criação tabela  redmine_dw.dim_tarefa

/*==============================================================*/
/* table: dim_tarefa                                            */
/*==============================================================*/
create table redmine_dw.dim_tarefa
(
   idw_tarefa           int not null auto_increment,
   id_tarefa            int not null,
   id_projeto           int not null,
   id_sprint            int,
   tipo_tarefa          varchar(30) not null,
   assunto              varchar(255),
   descricao_tarefa     text,
   status_tarefa        varchar(30) not null,
   atribuida_para       varchar(255),
   priority_id          int,
   autor                varchar(255),
   data_criacao         timestamp not null,
   data_prevista        date,
   data_atualizacao     timestamp,
   data_inicio          date,
   data_conclusao       datetime,
   percentual_concluido int,
   parent_id            int,
   root_id              int not null,
   primary key (idw_tarefa)
);

-----------------------

-- criação tabela  redmine_dw.ft_ss_redmine

/*==============================================================*/
/* table: ft_ss_redmine                                         */
/*==============================================================*/
create table redmine_dw.ft_ss_redmine
(
   idw_redmine          int not null auto_increment primary key,
   idw_projeto          int not null,
   idw_usuario          int,
   idw_data             int not null,
   idw_tarefa           int not null,
   idw_sprint           int,
   qt_tarefa            int not null,
   qt_profissional      int not null
);

alter table redmine_dw.ft_ss_redmine add constraint fk_dim_calendario_ft_redmine foreign key (idw_data)
      references redmine_dw.dim_calendario (idw_data) on delete restrict on update restrict;

alter table redmine_dw.ft_ss_redmine add constraint fk_dim_projeto_ft_redmine foreign key (idw_projeto)
      references redmine_dw.dim_projeto (idw_projeto) on delete restrict on update restrict;

alter table redmine_dw.ft_ss_redmine add constraint fk_dim_sprint_ft_redmine foreign key (idw_sprint)
      references redmine_dw.dim_sprint (idw_sprint) on delete restrict on update restrict;

alter table redmine_dw.ft_ss_redmine add constraint fk_dim_tarefa_ft_redmine foreign key (idw_tarefa)
      references redmine_dw.dim_tarefa (idw_tarefa) on delete restrict on update restrict;

alter table redmine_dw.ft_ss_redmine add constraint fk_dim_usuario_ft_redmine foreign key (idw_usuario)
      references redmine_dw.dim_usuario (idw_usuario) on delete restrict on update restrict;
	  
-----------------------------------------------------------------------------------------------------------------------------------

--  carga dim projeto

insert into redmine_dw.dim_projeto (id_projeto, nome, parent_id, descricao, identificador)
SELECT     
	 id,
	 name,
	 parent_id,
	 description,
	 identifier
FROM       
	 redmine_ods.projects
WHERE      
	 id in (7,49); 
-----------------------
insert into redmine_dw.dim_projeto (id_projeto, nome, parent_id, descricao, identificador)
with recursive cte (id, name, parent_id, description, identifier) as (
  select     
			 id,
             name,
             parent_id,
			 description,
			 identifier
  from       
			 redmine_ods.projects
  where      
			 parent_id in (7,49)
  union all
  select     
			 p.id,
             p.name,
             p.parent_id,
			 p.description,
			 p.identifier
  from       
			 redmine_ods.projects p
  inner join cte on p.parent_id = cte.id
)
select id, name, parent_id, description, identifier from cte order by parent_id, name;

-----------------------------------------------------------------------------------------------------------------------------------

--  carga dim_sprint

insert into redmine_dw.dim_sprint (id_sprint, nome, descricao, id_usuario, id_projeto, data_inicial, data_final, data_criacao, data_atualizacao, tipo_sprint)
with cte (id_sprint, nome, descricao, id_usuario, id_projeto, data_inicial, data_final, data_criacao, data_atualizacao, tipo_sprint) as (
	select 
		sp.id as id_sprint,
		sp.name as nome,
		sp.description as descricao,
		sp.user_id as id_usuario,
		sp.project_id as id_projeto,
		sp.sprint_start_date as data_inicial,
		sp.sprint_end_date as data_final,
		sp.created_on as data_criacao,
		sp.updated_on as data_atualizacao,
        case
			when sp.is_product_backlog = 1 then 'Backlog'
			else 'Sprint'
		end as tipo_sprint
	from
		redmine_ods.sprints as sp
	inner join
		redmine_dw.dim_projeto p on sp.project_id = p.id_projeto
	inner join
		redmine_ods.users u on sp.user_id = u.id
	/*where
		sp.is_product_backlog <> 1*/
)
select id_sprint, nome, descricao, id_usuario, id_projeto, data_inicial, data_final, data_criacao, data_atualizacao, tipo_sprint from cte order by nome, data_inicial;

-----------------------------------------------------------------------------------------------------------------------------------

--  carga dim_usuario

insert into redmine_dw.dim_usuario (id_usuario, nome, login, email, tipo, status, data_ultimo_login, data_criacao, data_atualizacao)
with cte (id_usuario, nome, login, email, tipo, status, data_ultimo_login, data_criacao, data_atualizacao) as (
	select 
		users.id as id_usuario,
		concat(users.firstname, ' ', users.lastname) as nome,
		users.login as login,
		ea.address as email,
		case
			when users.admin = 1 then 'administrador'
			else 'usuario'
		end as tipo,
		case
			when users.status = 1 then 'ativo'
			when users.status = 2 then 'registrado'
			else 'bloqueado'
		end as status,
		users.last_login_on as data_ultimo_login,
		users.created_on as data_criacao,
		users.updated_on as data_atualizacao
	from
		redmine_ods.users
	inner join 
		redmine_ods.email_addresses as ea on ea.user_id = users.id     
	where
		users.last_login_on is not null
)
select id_usuario, nome, login, email, tipo, status, data_ultimo_login, data_criacao, data_atualizacao from cte order by id_usuario;
-----------------------------------------------------------------------------------------------------------------------------------

--  carga dim_tarefa

insert into redmine_dw.dim_tarefa(
		id_tarefa, 
		id_projeto, 
		id_sprint, 
		tipo_tarefa, 
		assunto, 
		descricao_tarefa,
		status_tarefa,
		atribuida_para,
		priority_id,
		autor,
		data_criacao,
		data_prevista,
		data_atualizacao,
		data_inicio,
		data_conclusao,
		percentual_concluido,
		parent_id,
		root_id
	)
with cte (
		id_tarefa, 
		id_projeto, 
		id_sprint, 
		tipo_tarefa, 
		assunto, 
		descricao_tarefa,
		status_tarefa,
		atribuida_para,
		priority_id,
		autor,
		data_criacao,
		data_prevista,
		data_atualizacao,
		data_inicio,
		data_conclusao,
		percentual_concluido,
		parent_id,
		root_id
	) as (
	select 
		i.id,
		i.project_id as id_projeto,
		i.sprint_id as id_sprint,
		tr.name as tipo_tarefa,
		i.subject as assunto,
		i.description as descricao_tarefa,
		st.name as status_tarefa,
		u.login as atribuida_para,
		i.priority_id,
		u1.login as autor,
		i.created_on as data_criacao,
		i.due_date as data_prevista,
		i.updated_on as data_atualizacao,
		i.start_date as data_inicio,
		i.closed_on as data_conclusao,
		i.done_ratio as percentual_concluido,
		i.parent_id,
		i.root_id    
	from
		redmine_ods.issues as i
	inner join
		redmine_dw.dim_projeto p on i.project_id = p.id_projeto
	inner join    
		redmine_ods.trackers tr on i.tracker_id = tr.id
	inner join    
		redmine_ods.issue_statuses st on i.status_id = st.id 
	left join 
		redmine_dw.dim_usuario u on i.assigned_to_id = u.id_usuario 
	left join 
		redmine_dw.dim_usuario u1 on i.author_id = u1.id_usuario 
)
select 
	id_tarefa, 
	id_projeto, 
	id_sprint, 
	tipo_tarefa, 
	assunto, 
	descricao_tarefa,
	status_tarefa,
	atribuida_para,
	priority_id,
	autor,
	data_criacao,
	data_prevista,
	data_atualizacao,
	data_inicio,
	data_conclusao,
	percentual_concluido,
	parent_id,
	root_id 
from cte 
order by id_tarefa;	
-----------------------------------------------------------------------------------------------------------------------------------

--  carga ft_ss_redmine

insert into redmine_dw.ft_ss_redmine (idw_projeto, idw_data, idw_usuario, idw_tarefa, idw_sprint, qt_tarefa, qt_profissional)
with cte (idw_projeto, idw_data, idw_usuario, idw_tarefa, idw_sprint, qt_tarefa, qt_profissional) as (
	select
			p.idw_projeto as idw_projeto,
			(select idw_data from redmine_dw.dim_calendario where dt_data = curdate()) as idw_data, 
			usr.idw_usuario as idw_usuario,
			i.idw_tarefa as idw_tarefa,
			sp.idw_sprint as idw_sprint,
			count(i.id_tarefa) as qt_tarefa,
			count(i.atribuida_para) as qt_profissional
		from
			redmine_dw.dim_tarefa as i
		inner join
			redmine_dw.dim_projeto as p on i.id_projeto = p.id_projeto
		left join
			redmine_dw.dim_sprint as sp on i.id_sprint = sp.id_sprint
		left join
			redmine_dw.dim_usuario as usr on usr.login = i.atribuida_para
		group by i.id_projeto, i.idw_tarefa
		order by i.id_projeto, i.id_sprint
) 
select idw_projeto, idw_data, idw_usuario, idw_tarefa, idw_sprint, qt_tarefa, qt_profissional from cte ;

=================================================

--  carga dim_calendario

drop table if exists redmine_dw.dim_calendario;

/*==============================================================*/
/* table: dim_calendario                                        */
/*==============================================================*/
create table redmine_dw.dim_calendario
(
   idw_data             int not null,
   dt_data              date not null,
   nr_dia_semana        varchar(50) not null,
   nr_dia_mes           varchar(50) not null,
   nr_dia_ano           varchar(50) not null,
   nr_dia_epoca         int not null,
   nm_dia               varchar(50) not null,
   nr_dia_cal_juliano   int not null,
   ds_data              varchar(10) not null,
   ds_data_extenso      varchar(50) not null,
   ds_ano_mes_dia       int not null,
   ind_fim_semana       varchar(50) not null,
   ds_fim_semana        varchar(50) not null,
   ind_feriado          varchar(50) not null,
   ds_feriado           varchar(50) not null,
   ind_ultimo_dia_mes   varchar(50) not null,
   ds_ultimo_dia_mes    varchar(50) not null,
   cd_tp_data           varchar(50) not null,
   ds_tp_data           varchar(50) not null,
   nr_semana_ano        varchar(50) not null,
   nr_semana_epoca      int not null,
   dt_inicio_semana     date not null,
   dt_termino_semana    date not null,
   ds_semana            varchar(50) not null,
   nr_mes               varchar(50) not null,
   nr_mes_epoca         int not null,
   nm_mes               varchar(50) not null,
   sg_mes               varchar(50) not null,
   ds_anomes            int not null,
   ds_mesano            int not null,
   nr_trimestre         varchar(50) not null,
   ds_ano_trimestre     varchar(50) not null,
   nr_semestre          varchar(50) not null,
   ds_ano_semestre      varchar(50) not null,
   nr_ano               int not null,
   nr_ano_epoca         int not null,
   st_dia_util          varchar(50) not null,
   dt_proximo_dia_util  date not null,
   primary key (idw_data)
);
=================================================
/*
use redmine_dw;
load data infile 'd:/cade/banco-dados/dw/dm_data2.csv' 
into table redmine_dw.dim_calendario 
fields terminated by ';' 
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;*/
=================================================
select 
   idw_data
   ,dt_data            
   ,nr_dia_semana      
   ,nr_dia_mes         
   ,nr_dia_ano         
   ,nr_dia_epoca       
   ,nm_dia             
   ,nr_dia_cal_juliano 
   ,ds_data            
   ,ds_data_extenso    
   ,ds_ano_mes_dia     
   ,ind_fim_semana     
   ,ds_fim_semana      
   ,ind_feriado        
   ,ds_feriado         
   ,ind_ultimo_dia_mes 
   ,ds_ultimo_dia_mes  
   ,cd_tp_data         
   ,ds_tp_data         
   ,nr_semana_ano      
   ,nr_semana_epoca    
   ,dt_inicio_semana   
   ,dt_termino_semana  
   ,ds_semana          
   ,nr_mes             
   ,nr_mes_epoca       
   ,nm_mes             
   ,sg_mes             
   ,ds_anomes          
   ,ds_mesano          
   ,nr_trimestre       
   ,ds_ano_trimestre   
   ,nr_semestre        
   ,ds_ano_semestre    
   ,nr_ano             
   ,nr_ano_epoca       
   ,st_dia_util        
   ,dt_proximo_dia_util
from
    redmine_dw.dim_calendario;

=================================================
-- [DIM_GRAFO]:

with recursive cte (noFilho, noPai, nome) as (
	SELECT 
		du.idw_usuario as noFilho, 
		null as noPai,
		du.nome
	FROM redmine_dw.ft_ss_redmine as fr
	right join redmine_dw.dim_usuario as du on du.idw_usuario = fr.idw_usuario
	inner join redmine_dw.dim_tarefa as dt on (dt.idw_tarefa = fr.idw_tarefa and dt.atribuida_para = du.login)
	inner join redmine_dw.dim_projeto as dp on dp.idw_projeto = fr.idw_projeto
	where du.idw_usuario <> 1
	group by du.nome
	union all
	SELECT 
		dp.idw_projeto as noFilho, 
		du.idw_usuario as noPai,
		dp.nome
	FROM redmine_dw.ft_ss_redmine as fr
	right join redmine_dw.dim_usuario as du on du.idw_usuario = fr.idw_usuario
	inner join redmine_dw.dim_tarefa as dt on (dt.idw_tarefa = fr.idw_tarefa and dt.atribuida_para = du.login)
	inner join redmine_dw.dim_projeto as dp on dp.idw_projeto = fr.idw_projeto
	where du.idw_usuario <> 1
    and du.idw_usuario in (
		SELECT 
			du.idw_usuario
		FROM redmine_dw.ft_ss_redmine as fr
		right join redmine_dw.dim_usuario as du on du.idw_usuario = fr.idw_usuario
		inner join redmine_dw.dim_tarefa as dt on (dt.idw_tarefa = fr.idw_tarefa and dt.atribuida_para = du.login)
		inner join redmine_dw.dim_projeto as dp on dp.idw_projeto = fr.idw_projeto
		where du.idw_usuario <> 1
		group by du.nome
	)
)
select noFilho, noPai, nome from cte group by noFilho, noPai, nome order by noPai, nome;