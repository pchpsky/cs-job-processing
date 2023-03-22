defmodule JobsServiceWeb.JobControllerTest do
  use JobsServiceWeb.ConnCase, async: true

  describe "POST /api/jobs" do
    test "properly orders tasks", %{conn: conn} do
      tasks = [
        %{
          "name" => "task-4",
          "command" => "rm /tmp/file1",
          "requires" => [
            "task-2",
            "task-3"
          ]
        },
        %{
          "name" => "task-1",
          "command" => "touch /tmp/file1"
        },
        %{
          "name" => "task-2",
          "command" => "cat /tmp/file1",
          "requires" => [
            "task-3"
          ]
        },
        %{
          "name" => "task-3",
          "command" => "echo 'Hello World!' > /tmp/file1",
          "requires" => [
            "task-1"
          ]
        }
      ]

      conn = post(conn, "/api/jobs", %{"tasks" => tasks})
      assert conn.status == 200

      assert json_response(conn, 200)["tasks"] == [
               %{"name" => "task-1", "command" => "touch /tmp/file1"},
               %{"name" => "task-3", "command" => "echo 'Hello World!' > /tmp/file1"},
               %{"name" => "task-2", "command" => "cat /tmp/file1"},
               %{"name" => "task-4", "command" => "rm /tmp/file1"}
             ]

      assert json_response(conn, 200)["script"] ==
               String.trim("""
               #!/usr/bin/env bash
               touch /tmp/file1
               echo 'Hello World!' > /tmp/file1
               cat /tmp/file1
               rm /tmp/file1
               """)
    end

    test "returns error when tasks are not a list", %{conn: conn} do
      conn = post(conn, "/api/jobs", %{"tasks" => "not a list"})
      assert json_response(conn, 400)["error"] == "Tasks must be a non-empty list"
    end

    test "returns error when tasks are cyclic", %{conn: conn} do
      tasks1 = [
        %{
          "name" => "task-1",
          "command" => "touch /tmp/file1",
          "requires" => [
            "task-2"
          ]
        },
        %{
          "name" => "task-2",
          "command" => "cat /tmp/file1",
          "requires" => [
            "task-1"
          ]
        }
      ]

      conn = post(conn, "/api/jobs", %{"tasks" => tasks1})
      assert json_response(conn, 400)["error"] == "Tasks contain a cycle"

      tasks2 = [
        %{
          "name" => "task-1",
          "command" => "touch /tmp/file1",
          "requires" => [
            "task-2"
          ]
        },
        %{
          "name" => "task-2",
          "command" => "cat /tmp/file1",
          "requires" => [
            "task-3"
          ]
        },
        %{
          "name" => "task-3",
          "command" => "echo 'Hello World!' > /tmp/file1",
          "requires" => [
            "task-2"
          ]
        }
      ]

      conn = post(conn, "/api/jobs", %{"tasks" => tasks2})
      assert json_response(conn, 400)["error"] == "Tasks contain a cycle"

      task3 = [
        %{
          "name" => "task-1",
          "command" => "touch /tmp/file1",
          "requires" => [
            "task-2"
          ]
        },
        %{
          "name" => "task-2",
          "command" => "cat /tmp/file1",
          "requires" => [
            "task-3"
          ]
        },
        %{
          "name" => "task-3",
          "command" => "echo 'Hello World!' > /tmp/file1",
          "requires" => [
            "task-1",
            "task-4"
          ]
        },
        %{
          "name" => "task-4",
          "command" => "echo 'Hello World!' > /tmp/file1",
          "requires" => [
            "task-1"
          ]
        }
      ]

      conn = post(conn, "/api/jobs", %{"tasks" => tasks2})
      assert json_response(conn, 400)["error"] == "Tasks contain a cycle"
    end
  end
end
