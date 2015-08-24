use thomas_test;

drop table if exists test_table;

create table
	test_table
as select
	*
from
	capacity_combined

