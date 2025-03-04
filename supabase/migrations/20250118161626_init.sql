--
-- This SQL migration has been adapted to the project.
-- 
-- Source: Supabase Todo Quickstart with Row Level Security
--

-- Create the todos table with columns id, inserted_at, task, and user_id
create table todos (
  id bigint generated by default as identity primary key,
  inserted_at timestamp with time zone default timezone('utc'::text, now()) not null,
  task text check (char_length(task) > 3),
  user_id uuid references auth.users not null
);

-- Enable row level security on the todos table
alter table todos enable row level security;

-- Create policies for insert, select, update, and delete operations on the todos table
create policy "TODO_INSERT_POLICY" on todos for
    insert with check (auth.uid() = user_id);
create policy "TODO_SELECT_POLICY" on todos for
    select using (true);
create policy "TODO_UPDATE_POLICY" on todos for
    update using ((select auth.uid()) = user_id);
create policy "TODO_DELETE_POLICY" on todos for
    delete using ((select auth.uid()) = user_id);

-- Create a view todos_public_view to expose certain columns from the todos table
create view todos_public_view as
select
  id,
  inserted_at,
  task,
  case
    when auth.uid() = user_id then user_id
    else null
  end as user_id
from todos;

-- Create or replace the view todos_public_view with security invoker enabled
create or replace view public.todos_public_view with (security_invoker = on) as
select * from public.todos;
