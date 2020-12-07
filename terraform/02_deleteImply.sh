#!/usr/bin/env bash
set -e

echo "Delete Imply from K8s ..."
helm delete imply
