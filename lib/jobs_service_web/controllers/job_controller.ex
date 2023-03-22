defmodule JobsServiceWeb.JobController do
  use JobsServiceWeb, :controller

  def create(conn, %{"tasks" => tasks}) do
    case JobsService.JobBuilder.build(tasks) do
      {:ok, job} ->
        render(conn, "job.json", job: job)

      {:error, error} ->
        conn
        |> put_status(400)
        |> render("error.json", error: error)
    end
  end
end
