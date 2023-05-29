good_job = fn -> Process.sleep(5000); {:ok, []} end
bad_job = fn -> Process.sleep(3000); :error end
