defmodule JobsService.JobBuilder do
  def build([]) do
    {:error, "No tasks provided"}
  end

  def build(tasks) when is_list(tasks) do
    tasks_ordered = order_tasks(tasks)

    # TODO: detect cycles

    {:ok, %{tasks: tasks_ordered, script: build_script(tasks_ordered)}}
  end

  def build(_) do
    {:error, "Tasks must be a list"}
  end

  defp order_tasks(tasks) do
    tasks
    |> build_deps_map()
    |> order_deps([])
    |> Enum.map(fn task_name -> Enum.find(tasks, &(&1["name"] == task_name)) end)
    |> Enum.map(fn task -> Map.take(task, ["name", "command"]) end)
  end

  defp order_deps([], acc) do
    Enum.reverse(acc)
  end

  defp order_deps([task | rest], acc) do
    {resolved, rest} = resolve_dep(rest, task)

    order_deps(rest, resolved ++ acc)
  end

  defp resolve_dep(deps, {task, task_deps}) do
    to_resolve = Enum.filter(deps, fn {task, _} -> task in task_deps end)

    deps = drop_dep(deps, task)

    {resolved, rest} =
      Enum.reduce(to_resolve, {[], deps}, fn task, {acc, deps} ->
        if elem(task, 0) in acc do
          {acc, deps}
        else
          {resolved_tasks, new_deps} =
            deps
            |> List.delete(task)
            |> resolve_dep(task)

          {resolved_tasks ++ acc, new_deps}
        end
      end)

    {[task | resolved], rest}
  end

  defp drop_dep(deps, to_drop) do
    Enum.map(deps, fn {task, deps} -> {task, Enum.reject(deps, &(&1 == to_drop))} end)
  end

  defp build_deps_map(tasks) do
    Enum.map(tasks, fn task -> {task["name"], task["requires"] || []} end)
  end

  defp build_script(tasks) do
    tasks
    |> Enum.map(fn task -> task["command"] end)
    |> Enum.join("\n")
    |> then(&"#!/usr/bin/env bash\n#{&1}")
  end
end
