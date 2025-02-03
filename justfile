name := "bubylou/moria"
tag := `git describe --tags --abbrev=0`

docker := "docker.io" / name + ":" + tag
github := "ghcr.io" / name + ":" + tag

release-args := "--cache-from type=gha --cache-to type=gha,mode=max --attest type=provenance,mode=max"

default: test clean

build:
	buildah bud --build-args RELEASE=full -t {{docker}} -t {{github}} .

build-trim:
	buildah bud --build-arg RELEASE=trim -t {{docker}}-trim -t {{github}}-trim .

clean:
	podman stop moria-test

test: build-trim
	podman run --rm --detach --volume ./moria-app:/app/moria --name moria-test {{github}}-trim
	podman logs moria-test

release: build
	buildah bud --build-args RELEASE=full {{release-args}} -t {{docker}} -t {{github}} .

release-trim: build-trim
	buildah bud --build-args RELEASE=trim {{release-args}} -t {{docker}} -t {{github}} .
