create database votação_de_leis;
use votação_de_leis;

set sql_safe_updates=0;

create table usuarios
(
id_usuario int auto_increment primary key,
nome varchar(255) not null,
email varchar(255) unique not null,
cidade varchar(100) not null,
estado char(2) not null,
data_nascimento date not null
);
describe usuarios;

create table propostas_lei
(
id_proposta int auto_increment primary key,
titulo varchar(20) not null,
descricao text not null,
data_criacao datetime default current_timestamp,
status enum('proposta','em_votacao','aprovada','rejeitada') default 'proposta',
id_autor int not null,
foreign key (id_autor) references usuarios (id_usuario)
);
alter table propostas_lei modify column status enum('rascunho','proposta','em_votacao','aprovada','rejeitada') default 'proposta';
describe propostas_lei;

create table votacoes
(
id_votacao int auto_increment primary key,
voto enum('sim', 'não') not null,
data_voto datetime default current_timestamp,
id_usuario int not null,
id_proposta int not null,
foreign key (id_usuario) references usuarios (id_usuario),
foreign key (id_proposta) references propostas_lei (id_proposta)
);
describe votacoes;

 create table comentarios
(
id_comentario int auto_increment primary key,
texto text not null,
data_comentario datetime default current_timestamp,
id_usuario int not null,
id_proposta int not null,
foreign key (id_usuario) references usuarios (id_usuario),
foreign key (id_proposta) references propostas_lei (id_proposta)
);
describe comentarios;

create table historico_status
(
id_historico int auto_increment primary key,
status_anterior ENUM('rascunho', 'proposta', 'em_votacao', 'aprovada', 'rejeitada', 'arquivada'),
status_novo ENUM('rascunho', 'proposta', 'em_votacao', 'aprovada', 'rejeitada', 'arquivada'),
data_alteracao datetime default current_timestamp,
id_proposta int not null,
foreign key (id_proposta) references propostas_lei (id_proposta) 
);
describe historico_status;

insert into usuarios (nome, email, cidade, estado, data_nascimento) values
('Ana Silva', 'ana.silva@email.com', 'São Paulo', 'SP', '1985-03-12'),
('Bruno Costa', 'bruno.costa@email.com', 'Rio de Janeiro', 'RJ', '1990-07-25'),
('Carla Dias', 'carla.dias@email.com', 'Belo Horizonte', 'MG', '1982-11-05'),
('Daniel Alves', 'daniel.alves@email.com', 'Curitiba', 'PR', '1978-01-20'),
('Eduarda Lima', 'eduarda.lima@email.com', 'Porto Alegre', 'RS', '1995-09-15'),
('Fábio Souza', 'fabio.souza@email.com', 'Fortaleza', 'CE', '1988-04-30'),
('Gabriela Rocha', 'gabriela.rocha@email.com', 'Salvador', 'BA', '1992-12-01'),
('Hugo Pereira', 'hugo.pereira@email.com', 'Recife', 'PE', '1987-06-17'),
('Isabela Martins', 'isabela.martins@email.com', 'Manaus', 'AM', '1991-08-09'),
('João Fernandes', 'joao.fernandes@email.com', 'Brasília', 'DF', '1983-05-22');

insert into propostas_lei (titulo, descricao, id_autor) values
('Lei Ambiental', 'Proposta para preservação das áreas verdes.', 1),
('Lei Educação', 'Melhoria da qualidade da educação básica.', 2),
('Lei Saúde', 'Ampliação dos serviços públicos de saúde.', 3),
('Lei Trânsito', 'Reformas nas regras de trânsito urbano.', 4),
('Lei Cultura', 'Incentivo à cultura local.', 5),
('Lei Segurança', 'Reforço no policiamento comunitário.', 6),
('Lei Tecnologia', 'Fomento à inovação tecnológica.', 7),
('Lei Moradia', 'Programas de habitação popular.', 8),
('Lei Transporte', 'Melhorias no transporte público.', 9),
('Lei Trabalho', 'Regulamentação do home office.', 10);
select * from propostas_lei;

insert into votacoes (voto, id_usuario, id_proposta) values
('sim', 1, 1),
('não', 2, 1),
('sim', 3, 2),
('sim', 4, 3),
('não', 5, 4),
('sim', 6, 5),
('não', 7, 6),
('sim', 8, 7),
('sim', 9, 8),
('não', 10, 9);

insert into comentarios (texto, id_usuario, id_proposta) values
('Acho essencial essa lei.', 1, 1),
('Precisamos debater mais.', 2, 1),
('Ótima iniciativa!', 3, 2),
('Apoio totalmente.', 4, 3),
('Tenho dúvidas sobre o impacto.', 5, 4),
('Seria importante incluir mais detalhes.', 6, 5),
('Concordo com os pontos apresentados.', 7, 6),
('Sugiro revisão no artigo 3.', 8, 7),
('Lei fundamental para a cidade.', 9, 8),
('Fico contra essa proposta.', 10, 9);
select * from comentarios;

insert into historico_status (status_anterior, status_novo, id_proposta) values
('rascunho', 'proposta', 1),
('proposta', 'em_votacao', 1),
('em_votacao', 'aprovada', 1),
('rascunho', 'proposta', 2),
('proposta', 'em_votacao', 2),
('em_votacao', 'rejeitada', 2),
('rascunho', 'proposta', 3),
('proposta', 'em_votacao', 3),
('em_votacao', 'arquivada', 3),
('rascunho', 'proposta', 4);

# com essa view você poder observar com maior facilidade as propostas com autores
create view vw_propostas_com_autores as
select * from propostas_lei P
join usuarios U on P.id_proposta = U.id_usuario;

# com essa trigger é possível obter a alteração automática da tabela propostas_lei
delimiter $$

create trigger trg_after_status_update
after update on propostas_lei
for each row
begin
if old.status <> new.status then
insert into historico_status (status_anterior, status_novo, data_alteracao, id_proposta)
values (old.status, new.status, NOW(), new.id_proposta);
end if;
end$$

delimiter ;

select id_proposta, status from propostas_lei where id_proposta = 1;

update propostas_lei
set status = 'rejeitada'
where id_proposta = 1;

select * from historico_status where id_proposta = 1 order by data_alteracao desc;
