/**
 * Service Industry Order Management
 * @platform SQL Server 2022
 * @auther Alven Zhan
 * @version 1.3.0
 * @date '26w3d6a'
 * @release
 * @educational edition
 */

-- DataBase

create database SvOrder
on primary (
  name = mdfSvOrder,
  filename = '/var/opt/mssql/SvOrder/main.mdf',
  size = 8MB,
  filegrowth = 5%,
  maxsize = 4GB
) log on (
  name = ldfSvOrder,
  filename = '/var/opt/mssql/SvOrder/main.ldf',
  size = 1MB,
  filegrowth = 5%,
  maxsize = 256MB
);
go
---- Switch to DataBase

use SvOrder;
go
---- add files

alter database SvOrder
add file(
  name= ndfSvOrder,
  filename='/var/opt/mssql/SvOrder/main.ndf',
  size=5,
  maxsize=10,
  filegrowth=10%
);
go

alter database SvOrder
add log file(
  name= ldfSubSvOrder,
  filename='/var/opt/mssql/SvOrder/sub.ldf',
  size=5,
  maxsize=10,
  filegrowth=10%
);
go
---- remove file

alter database SvOrder
remove file ldfSubSvOrder;
go
/*
---- modify DB name

alter database SvOrder
modify name = clubOrder;
go
---- detach DB

exec sp_detach_db clubOrder;
go
---- attach to link

create database clubOrder
on(
  filename='/var/opt/mssql/SvOrder/main.mdf'
)for attach;
go
---- remove full of DB

drop database clubOrder;
go
*/
-- Tables

---- Tables Basic

create table Personnel (
  id char(6) not null primary key,
  name nvarchar(24) not null,
  tel varchar(12) not null unique,
  store smallint null,
  branch tinyint null,
  type char(4) null,
  deleted bit not null default 0,
  constraint uq_Personnel_tel unique(tel)
);

create table Customer (
  id char(8) not null primary key,
  name nvarchar(24) not null,
  tel varchar(12) not null unique,
  deleted bit not null default 0,
  constraint uq_Customer_tel unique(tel)
);

create table Member (
  id char(8) not null,
  store smallint not null,
  balance decimal(8, 2) not null default 0.00,
  points int not null default 0,
  deleted bit not null default 0,
  constraint pk_Member
    primary key (id, store)
);

create table Store (
  id smallint not null primary key identity(1001, 1),
  host char(6) not null foreign key references Personnel(id),
  name nvarchar(24) not null,
  deleted bit not null default 0
);

create table Branch ( -- Weak Entity
  id tinyint not null,
  belong smallint not null foreign key references Store(id),
  name nvarchar(24) not null,
  longit decimal(8, 5) null,
  latit decimal(7, 5) null,
  tst tinyint null,
  ted tinyint null,
  festival tinyint null,
  deleted bit not null default 0,
  constraint pk_Branch
    primary key(belong, id),
);

create table Orders (
  dt smalldatetime not null default dateadd(year, -100, getdate()),
  psn char(6) not null foreign key references Personnel(id),
  vst char(8) not null foreign key references Customer(id),
  sto smallint not null,
  brc tinyint not null,
  oam decimal(8, 2) not null default 0.00,
  dam decimal(8, 2) not null default 0.00,
  method char(6) not null,
  payment varchar(32) not null unique,
  deleted bit not null default 0,
  constraint pk_Order
    primary key (dt, psn, vst),
  constraint fk_Order_Branch
    foreign key(sto, brc)
      references Branch(belong, id)
);
go
---- alter constraint fk, ck

alter table Personnel
  add constraint fk_Personnel_Branch
    foreign key (store, branch)
      references Branch(belong, id);

alter table Store
  add constraint fk_Store_host
    foreign key (host)
      references Personnel(id);

alter table Member
  add constraint fk_Member_id
    foreign key (id)
      references Customer(id);

alter table Member
  add constraint fk_Member_store
    foreign key (store)
      references Store(id);

alter table Personnel
  add constraint ck_Personnel_tel
    check (
      (len(tel) = 11 and tel like '1[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
      or
      (len(tel) = 12 and tel like replicate('[0-9]', 12))
    );

alter table Customer
  add constraint ck_Customer_tel
    check (
      (len(tel) = 11 and tel like '1[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
      or
      (len(tel) = 12 and tel like replicate('[0-9]', 12))
    );
go

alter table Personnel
add age int;
go
alter table Personnel
add constraint ck_Personnel_age check(age>18);
go
alter table Personnel
drop constraint ck_Personnel_age;
go

alter table Personnel
drop column age;
/*
drop table Personnel;
*/
go
-- insert test data

insert into Customer
  values('20010000', N'散客', '500000000000', 0)

insert into Personnel(id, name, tel)
  values('240101', N'赵祥', '10085360313');

insert into Personnel(id, name, tel)
  values('240102', N'李强', '10085340414');

insert into Personnel(id, name, tel)
  values('240103', N'张智', '10085320515');

insert into Store(host, name)
  values('240101', N'茶与发艺');

insert into Branch(belong, id, name, longit, latit)
  values(1001, 1, N'总店', 119.75057, 36.34527);

insert into Branch(belong, id, name, longit, latit)
  values(1001, 2, N'科大店', 119.75057, 36.34527);

insert into Customer
  values('24010101', N'王超', '10085360123', 0);

insert into Member
  values('24010101', 1001, 0, 0, 0);

insert into Customer
  values('24010201', N'刘仁', '10085360124', 0);

insert into Member
  values('24010201', 1001, 0, 0, 0);

insert into Customer
  values('24010202', N'徐克', '10085360125', 0);

insert into Member
  values('24010202', 1001, 0, 0, 0);

insert into Orders
  values('1925-10-01 15:30', '240101', '20010000', 1001, 1, 30.0, 30.0, 'AliPay', '100010TMEP01TEST', 0);
go

update Member
  set balance = 100
  where id = '24010101';

update Personnel
  set deleted = 1
  where id = '240103';

update Personnel
  set store = 1001, branch = 1
  where id = '240102';

update Personnel
  set store = 1001, branch = 1, type = 'host'
  where id = 240101;

delete
  from Branch
  where belong = 1001 and id = 2;
go

insert into Branch(id, belong, name, longit, latit)
  values(2, 1001, N'南湖分店', 119.76471, 36.35455);

insert into Personnel
  values('240104', N'刘胜', '10085360876', 1001, 2, 'host', 0);

insert into Orders
  values('1925-10-02 12:00', '240104', '24010101', 1001, 2, 30, 28, 'WeChat', '100010TMEP02TEST', 0);

insert into Orders
  values('1925-10-05 14:01', '240104', '24010202', 1001, 1, 30, 25, 'CnUniP', '100010TMEP03TEST', 0);
go
-- select

---- list all stores in system 列出系统中所有店铺

select id, host, name
  from store;

---- list all the member and balance of the Store 列出店铺所有会员

select name as 顾客, balance as 储蓄账户, points as 积分
  from Member, Customer
  where Member.id = Customer.id and Member.store = 1001;

---- list all member account of one customer 列出该顾客所有会员账号

select name as 店铺, balance as 储蓄账户, points as 积分
  from Member, Store
  where Member.store = Store.id and Member.id = '24010101';

---- list all the branch of the store 列出店铺所有分店

select name as 店名, id as ID
  from Branch
  where belong = 1001;

/*以下查询在此案例的实机测试中应尽量放宽时间限制，或者插入更新的订单记录。
  时间加密方式为当前时间-100年。
  解密方式参照函数部分。*/
---- list all orders of one personnel in the latest 90 days 列出90日内一个人员的所有的订单

select dt as 时间, brc as 分店, dam as 优惠后金额, method as 支付方式
  from Orders
  where deleted = 0 and psn = '240104' and dt < dateadd(year, -100, getdate()) and dt > dateadd(year, -100, dateadd(day, -90, getdate()));

---- list all orders with customer's infomation of onr personnel in the latest 90 days 列出90日内一个人员所有订单包含的详细信息

select dt as 时间, brc as 分店, dam as 优惠后金额, Customer.name as 顾客, method as 支付方式, payment as 付款单号, Customer.id as 顾客ID
  from Orders, Customer
  where Orders.vst = Customer.id and Orders.deleted = 0 and psn = '240104' and dt < dateadd(year, -100, getdate()) and dt > dateadd(year, -100, dateadd(day, -120, getdate()));

---- list all personnel who has NO orders in the latest 90 days 列出近90日内没有订单的员工

select Personnel.id as 员工号, Personnel.name as 姓名, replace(N'最近{dd}天无订单', '{dd}', cast(90 as char(2))) as 备注
  from Orders right outer join Personnel
  on Orders.psn = Personnel.id and sto = 1001 and dt < dateadd(year, -100, getdate()) and dt > dateadd(year, -100, dateadd(day, -90, getdate()))
  group by id, name, Orders.dt
  having dt is null
  order by 姓名;

---- list all customer who has never visited in the latest 90 days 列出近90日内未光临的顾客

select id as 顾客ID, replace(N'最近{dd}天无订单', '{dd}', cast(90 as char(2))) as 备注
  from Member left outer join Orders
  on Orders.vst = Member.id and sto = 1001 and dt < dateadd(year, -100, getdate()) and dt > dateadd(year, -100, dateadd(day, -90, getdate()))
  group by id, Orders.dt
  having dt is null;
go
-- view

---- list all stores in system 列出系统中所有店铺

create view view_Store as
  select id, host, name
    from store;
go
---- list all the branch of the store 列出店铺所有分店

create view view_Branch_by_Store as
  select name as 店名, id as ID, longit as 经度, latit as 纬度, belong as 店铺
    from Branch
    where belong = 1001;
go
---- list all orders of one personnel in the latest 90 days 列出90日内一个人员的所有的订单

create view view_Orders_by_Customer as
  select dt as 时间, brc as 分店, dam as 优惠后金额, method as 支付方式
    from Orders
    where deleted = 0 and psn = '240104' and dt < dateadd(year, -100, getdate()) and dt > dateadd(year, -100, dateadd(day, -90, getdate()));
go
---- list all personnel who has NO orders in the latest 90 days 列出近90日内没有订单的员工

create view view_Personnel_Orders as
  select Personnel.id as 员工号, Personnel.name as 姓名, replace('最近{dd}天无订单', '{dd}', cast(90 as char(2))) as 备注
    from Orders right outer join Personnel
    on Orders.psn = Personnel.id and sto = 1001 and dt < dateadd(year, -100, getdate()) and dt > dateadd(year, -100, dateadd(day, -90, getdate()))
    group by id, name, Orders.dt
    having dt is null;
go
---- list all customer who has never visited in the latest 90 days 列出近90日内未光临的顾客

create view view_Member_Orders as
  select id as 顾客ID, replace('最近{dd}天无订单', '{dd}', cast(90 as char(2))) as 备注
    from Member left outer join Orders
    on Orders.vst = id and sto = 1001 and dt < dateadd(year, -100, getdate()) and dt > dateadd(year, -100, dateadd(day, -90, getdate()))
    group by id, Orders.dt
    having dt is null;
go

---- insert a branch into the store

insert into view_Branch_by_Store(ID, 店名, 经度, 纬度, 店铺)
  values(3, N'顺河路店', 119.75876, 36.38289, 1001);
go

---- insert into a bytabled view (will be refused)
/*
insert into view_Personnel_Orders(员工号, 姓名, 备注)
  values('240103', '张智', '00');
go
*/

-- procedure

---- function for encode time

create function func_time (
  @input datetime2(0) = null
) returns smalldatetime
  as
  begin
    if @input is null
      set @input = getdate();
    declare @res smalldatetime;
    set @res = try_cast(dateadd(year, -100, @input) as smalldatetime);
    return @res;
  end;
go

create function times (
  @input datetime2(0) = null
) returns smalldatetime
  as
  begin
    return dbo.func_time(@input);
  end;
go

---- function for decode time

create function func_show_time (
  @input smalldatetime = null
) returns datetime2(0)
  as
  begin
    if @input is null
      set @input = getdate();
    declare @res datetime;
    set @res = try_cast(dateadd(year, 100, @input) as datetime2(0));
    return @res;
  end;
go

create function timex (
  @input smalldatetime = null
) returns datetime2(0)
  as
  begin
    return dbo.func_show_time(@input)
  end;
go
---- list the Orders from to

create procedure showOrders
  @from datetime2(0) = null,
  @to datetime2(0) = null,
  @store smallint,
  @branch tinyint = null,
  @personnel char(6) = null
as begin
  declare @from_psd smalldatetime;
  declare @to_psd smalldatetime;
  if @from is null
    set @from_psd = dbo.times(dateadd(month, -1, getdate()));
  else
    set @from_psd = dbo.times(@from);
  set @to_psd = dbo.times(@to);
  if @personnel is not null and @branch is not null
    select dbo.timex(dt) as 时间, brc as 分店, dam as 优惠后金额, method as 支付方式
      from Orders
      where deleted = 0 and psn = @personnel and dt < @to_psd and dt > @from_psd and sto = @store and brc = @branch;
  else if @personnel is not null
    select dt as 时间, brc as 分店, dam as 优惠后金额, method as 支付方式
      from Orders
      where deleted = 0 and psn = @personnel and dt < @to_psd and dt > @from_psd and sto = @store;
  else if @branch is not null
    select dt as 时间, brc as 分店, dam as 优惠后金额, method as 支付方式
      from Orders
      where deleted = 0 and dt < @to_psd and dt > @from_psd and sto = @store and brc = @branch;
  else
    select dt as 时间, brc as 分店, dam as 优惠后金额, method as 支付方式
      from Orders
      where deleted = 0 and dt < @to_psd and dt > @from_psd and sto = @store;
end;
go
---- list all personnel in the store

create procedure showPersonnel
  @store smallint,
  @branch tinyint = null
as begin
  if @branch is not null
    select id, name, tel, type
      from Personnel
      where store = @store and branch = @branch;
  else
    select id, name, tel, type
      from Personnel
      where store = @store;
end;
go
---- list all member account owned by a customer

create procedure showMember
  @customer char(8)
as begin
  select store as 店铺, name as 店名, balance as 存款, points as 积分
    from Member, Store
    where Member.store = Store.id and Member.id = @customer;
end;
go
---- list receipts of all personnel in the latest d days 列出员工的订单流水

create procedure showGrossReceipts
  @store smallint,
  @branch tinyint = null,
  @from datetime2(0),
  @to datetime2(0),
  @isasc bit = null
as begin
  if @branch is not null
    select Personnel.id as 员工号, Personnel.name as 姓名, sum(dam) as 流水, tel as 联系方式
      from Orders right outer join Personnel
      on Orders.psn = Personnel.id and Personnel.store = @store and personnel.branch = @branch and sto = @store and dt < dbo.times(@to) and dt > dbo.times(@from) and brc = @branch
      group by id, name, tel
      order by
        case when @isasc = 1 then sum(dam) end asc,
        case when @isasc <> 1 or @isasc is null then sum(dam) end desc;
  else
    select Personnel.id as 员工号, Personnel.name as 姓名, brc as 分店, sum(dam) as 流水, tel as 联系方式
      from Orders right outer join Personnel
      on Orders.psn = Personnel.id and personnel.store = @store and sto = @store and dt < dbo.times(@to) and dt > dbo.times(@from)
      group by id, name, tel, brc
      order by
        case when @isasc = 1 then sum(dam) end asc,
        case when @isasc <> 1 or @isasc is null then sum(dam) end desc;
end;
go
---- 查询一个客户所有订单

create procedure showCustomerOrder
  @customer char(8),
  @store smallint = null,
  @branch tinyint = null
as begin
  select dbo.timex(dt) as 日期, Personnel.name as 服务人员, sto as 店铺, brc as 分店, dam as 实付, method as 支付方式
    from Orders, Personnel
    where psn = Personnel.id and (@store is null or sto = @store) and (@branch is null or brc = @branch);
end;
go
---- 创建新订单

create procedure mergeOrder
  @store smallint,
  @branch tinyint,
  @personnel char(6),
  @customer char(8) = null,
  @origin decimal(8, 2),
  @discounted decimal(8, 2),
  @pay_method char(6),
  @payment_number varchar(32)
as begin
  if @customer is null
    set @customer = '20010000';
  insert into Orders
    values(dbo.times(null), @personnel, @customer, @store, @branch, @origin, @discounted, @pay_method, @payment_number, 0);
end;
go
---- 注册新人员

create procedure mergePersonnel
  @telephone varchar(12),
  @name nvarchar(24),
  @store smallint = null,
  @branch tinyint = null,
  @type char(4) = null
as begin
  declare @yymm char(4);
  set @yymm = format(getdate(), 'yyMM');
  declare @max_seq tinyint;
  set @max_seq = 0;
  select @max_seq = max(cast(right(id, 2) as tinyint))
    from Personnel
    where id LIKE @yymm + '%';
  if @max_seq is null set @max_seq = 0;
  insert into Personnel
    values(@yymm + right(format(@max_seq + 1, '00'), 2), @name, @telephone, @store, @branch, @type, 0);
end;
go
---- 注册新店铺以及分店

create procedure mergeStoreBranch
  @store smallint,
  @is_branch bit = null,
  @host_personnel char(6),
  @name nvarchar(24)
as begin
  if @is_branch = 1 begin
    declare @max_seq tinyint, @tmp_check tinyint
    select @tmp_check = branch
      from Personnel
      where id = @host_personnel;
    if @tmp_check is not null
      return;
    select @max_seq = max(id)
      from Branch
      where belong = @store;
    if @max_seq is null set @max_seq = 0;
    insert into Branch(id, belong, name)
      values(@max_seq + 1, @store, @name);
    update Personnel
      set store = @store, branch = @max_seq + 1, type = 'host'
      where id = @host_personnel;
  end;
  else
    insert into Store
      values(@host_personnel, @name, 0);
end;
go
---- 入职

create procedure onboard
  @personnel char(6),
  @store smallint,
  @branch tinyint,
  @is_admin bit
as begin
  declare @tmp_check tinyint;
  select @tmp_check = branch
    from Personnel
    where id = @personnel;
  if @tmp_check is not null
    return;
  update Personnel
    set store = @store, branch = @branch, type = case @is_admin
      when 1 then 'admn'
      when 0 then 'mpee'
    end
    where id = @personnel;
end;
go
---- 注册顾客

create procedure mergeCustomer
  @name nvarchar(24),
  @telephone varchar(12)
as begin
  declare @max_seq tinyint, @yymmdd char(6);
  set @yymmdd = format(getdate(), 'yyMMdd');
  select @max_seq = max(cast(right(id, 2) as tinyint))
    from Customer
    where id like @yymmdd + '%';
  if @max_seq is null set @max_seq = 0;
  insert into Customer
    values(@yymmdd + right(format(@max_seq + 1, '00'), 2), @name, @telephone, 0);
end;
go
---- 注册会员

create procedure mergeMember
  @id char(8),
  @store smallint
as begin
  insert into Member
    values(@id, @store, 0, 0, 0);
end;
go
---- 店内快速注册

create procedure mergeMemFast
  @name nvarchar(24),
  @telephone varchar(12),
  @store smallint
as begin
  declare @max_seq tinyint, @yymmdd char(6);
  set @yymmdd = format(getdate(), 'yyMMdd');
  select @max_seq = max(cast(right(id, 2) as tinyint))
    from Customer
    where id like @yymmdd + '%';
  if @max_seq is null set @max_seq = 0;
  insert into Customer
    values(@yymmdd + right(format(@max_seq + 1, '00'), 2), @name, @telephone, 0);
  insert into Member
    values(@yymmdd + right(format(@max_seq + 1, '00'), 2), @store, 0, 0, 0);
end;
go

-- trigger

---- delete rejection

create trigger reject_modify_Orders
  on Orders
  for delete, update
as begin
  set nocount on;
  rollback;
end;
go

create trigger reject_delete_Personnel
  on Personnel
  for delete
as begin
  set nocount on;
  rollback;
end;
go

create trigger reject_delete_Member
  on Member
  for delete
as begin
  set nocount on;
  rollback;
end;
go

create trigger reject_delete_Customer
  on Customer
  for delete
as begin
  set nocount on;
  rollback;
end;
go

create trigger reject_delete_Branch
  on Branch
  for delete
as begin
  set nocount on;
  rollback
end;
go

create trigger reject_delete_Store
  on Store
  for delete
as begin
  set nocount on;
  rollback;
end;
go

---- 限制单一店长
create trigger trg_Personnel_OneHostPerBranch
  on Personnel
  after insert, update
as
begin
  set nocount on;

  if exists (
    select 1
    from Personnel p
    join inserted i
      on p.store = i.store
     and p.branch = i.branch
    where p.type = 'Host'
      and p.deleted = 0
    group by p.store, p.branch
    having count(*) > 1
  )
  begin
    rollback tran;
    throw 50001, N'一个分店只能有一个店长', 1;
  end
end;
go

---- 余额扣减
create trigger trg_Order_MemberBalance
  on Orders
  after insert
as
begin
  set nocount on;

  if exists (
    select 1
    from inserted i
    left join Member m
      on m.id = i.vst
     and m.store = i.sto
     and m.deleted = 0
    where i.method = 'Member'
      and (m.id is null or m.balance < i.dam)
  )
  begin
    rollback tran;
    throw 50002, N'会员余额不足或会员不存在', 1;
  end

  update m
  set m.balance = m.balance - i.dam
  from Member m
  join inserted i
    on m.id = i.vst
   and m.store = i.sto
  where i.method = 'Member';
end;
go
