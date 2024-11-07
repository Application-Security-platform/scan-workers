from fastapi import FastAPI, UploadFile, File, Form, HTTPException, BackgroundTasks, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from facade import RepositoryFacade
import subprocess

app = FastAPI()
templates = Jinja2Templates(directory="templates")

@app.get("/", response_class=HTMLResponse)
async def get_form(request: Request):
    return templates.TemplateResponse("upload.html", {"request": request})

@app.post("/repository/")
async def handle_repository(
    background_tasks: BackgroundTasks,
    repo_type: str = Form(...), 
    repo_name: str = Form(...), 
    user: str = Form(...),
    repo_file: UploadFile = File(None), 
    repo_url: str = Form(None)
):
    if repo_type == "upload":
        if not repo_file:
            raise HTTPException(status_code=400, detail="No file provided.")
        
        # Schedule the upload task in the background
        background_tasks.add_task(RepositoryFacade.handle_upload, repo_name, repo_file.file)
        return {"message": "Repository is being processed in the background."}

    elif repo_type == "url":
        if not repo_url:
            raise HTTPException(status_code=400, detail="Repository URL is required.")

        try:
            # Validate the repository URL using git ls-remote
            result = subprocess.run(
                ["git", "ls-remote", repo_url],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            if result.returncode != 0:
                raise HTTPException(status_code=400, detail="Invalid repository URL: " + result.stderr)

            # Schedule the full clone task in the background
            background_tasks.add_task(RepositoryFacade.clone_repo_from_url, repo_name, repo_url)
            return {"message": "Repository cloning is being processed in the background."}
        except subprocess.CalledProcessError as e:
            raise HTTPException(status_code=400, detail="Invalid repository URL: " + str(e))
    
    else:
        raise HTTPException(status_code=400, detail="Invalid repository type.")
