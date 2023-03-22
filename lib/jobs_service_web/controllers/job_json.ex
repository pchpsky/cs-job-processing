defmodule JobsServiceWeb.JobJSON do
  def render("job.json", %{job: job}) do
    job
  end

  def render("error.json", %{error: message}) do
    %{error: message}
  end
end
